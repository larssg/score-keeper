class Match < ActiveRecord::Base
  attr_accessor :postpone_ranking_update

  # Virtual attributes for match info
  attr_accessor :score1, :team1
  attr_accessor :score2, :team2

  attr_accessor :filter

  belongs_to :account
  belongs_to :game, :counter_cache => true, :touch => true
  has_many :teams
  has_many :comments
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'

  before_save :set_played_on_and_at
  before_validation(:on => :create) { build_teams }
  after_create :update_winners
  after_create :update_rankings
  after_create :update_positions
  after_create :log
  before_destroy :update_after_destroy
  after_destroy :reset_rankings_after_destroy
  after_destroy :remove_log

  validates_presence_of :game
  validates_presence_of :team_one
  validates_presence_of :team_two

  validates_presence_of :score1, :score2, :team1, :team2
  
  validate :not_locked
  validate :unique_participants

  def self.per_page
    20
  end

  def self.recent_options(filter, options = {})
    default_options = { :order => 'played_at DESC' }

    game = options.delete(:game)
    if filter.blank?
      options[:total_entries] = game.matches_count unless game.nil?
    else
      if filter.index(',')
        conditions = ['team_one = ? OR team_two = ?', filter, filter]
        options[:total_entries] = Match.count(:conditions => conditions)
      else
        conditions = ["team_one = ? OR team_one LIKE ? OR team_one LIKE ? OR team_two = ? OR team_two LIKE ? OR team_two LIKE ?", filter, filter + ',%', '%,' + filter, filter, filter + ',%', '%,' + filter]
        options[:total_entries] = game.memberships.count(:conditions => ['memberships.user_id = ?', filter])
      end
    end
    options[:conditions] = conditions if conditions

    default_options.merge(options)
  end

  def self.find_recent(filter, options = {})
    matches = find(:all, recent_options(filter, options))
  end

  def self.find_filter_users(filter)
    return unless filter
    User.find(:all, :conditions => ['id IN (?)', filter.split(',').collect{ |id| id.to_i }], :order => 'display_name, name')
  end

  def self.sort_teams_by_filter(teams, filter)
    return teams if teams.size < 2
    if filter.blank?
      return (teams.first.score > teams.last.score) ? teams : teams.reverse
    else
      return (teams.first.matches_filter(filter)) ? teams : teams.reverse
    end
  end

  def winner
    @winner ||= self.teams.sort_by(&:score).last
  end

  def loser
    @loser ||= self.teams.sort_by(&:score).first
  end

  def positions
    self.position_ids.blank? ? nil : self.position_ids.split(',').collect(&:to_i)
  end

  def positions=(game_participations)
    self.position_ids = game_participations.collect(&:user_id).join(',')
  end

  def self.reset_rankings(game)
    return if game.nil?
    game.game_participations.update_all("game_participations.ranking = 2000, game_participations.matches_played = 0")
    game.matches.all.each do |match|
      match.update_rankings
      match.teams.each do |team|
        team.memberships.each do |membership|
          GameParticipation.update_all("game_participations.matches_played = game_participations.matches_played + 1", "game_participations.user_id = #{membership.user_id} AND game_participations.game_id = #{game.id}")
        end
      end
      match.update_positions
    end
  end

  def update_rankings
    return if self.teams.count < 2
    transfer = (0.01 * self.loser.ranking_total.to_f).round
    self.loser.award_points(-1 * transfer)
    self.winner.award_points(transfer)
  end

  def update_winners
    self.teams.each do |team|
      team.memberships.each do |membership|
        participation = membership.game_participation

        participation.increment(:matches_won) if team == self.winner
        participation.points_for += team.score
        participation.points_against += team.other.score
        participation.matches_played = self.game.memberships.count(:conditions => { :user_id => membership.user_id })
        participation.increment(:clean_sheets) if team.other.score == 0

        participation.save
      end

      team.update_attribute :won, team == self.winner
    end
  end

  def update_positions
    self.positions = self.game.ranked_game_participators
    # Using update_all to avoid callbacks being called
    Match.update_all("position_ids = '#{self.position_ids}'", "id = #{self.id}")
  end

  def update_after_destroy
    self.teams.each do |team|
      team.memberships.each do |membership|
        participation = membership.game_participation

        participation.decrement(:matches_won) if team == self.winner
        participation.points_for -= team.score
        participation.points_against -= team.other.score
        participation.decrement(:matches_played)
        participation.decrement(:clean_sheets) if team.other.score == 0

        participation.save
      end
    end

    self.teams.each do |team|
      team.memberships.each { |m| m.destroy }
      team.destroy
    end
  end

  def reset_rankings_after_destroy
    Match.reset_rankings(self.game) unless @postpone_ranking_update
  end

  def title()
    [ self.teams.first.display_names.join(' - '),
      "(#{self.teams.first.score} - #{self.teams.last.score})",
      self.teams.last.display_names.join(' - ')
    ].join(' ')
  end

  def log
    return if self.account.blank?
    self.account.logs.create(:linked_model => self.class.name,
                             :linked_id => self.id,
                             :user => self.creator,
                             :game => self.game,
                             :message => "%#{self.winner.memberships.collect { |m| m.user_id }.join('% and %')}% won #{self.winner.score} to #{self.loser.score} over %#{self.loser.memberships.collect { |m| m.user_id }.join('% and %')}%",
                             :published_at => self.played_at)
                             
    if self.game.track_clean_sheets? && (self.teams.first.score == 0 || self.teams.last.score == 0)
      self.account.logs.create(:linked_model => "Clean sheet",
                               :linked_id => self.id,
                               :user => self.creator,
                               :game => self.game,
                               :message => "%#{self.winner.memberships.collect { |m| m.user_id }.join('% and %')}% kept a clean sheet against %#{self.loser.memberships.collect { |m| m.user_id }.join('% and %')}%",
                               :published_at => self.played_at)
    end                         
  end

  protected
  def not_locked
    errors.add :game, 'is locked' if self.game.locked
  end
  
  def unique_participants
    user_ids = []

    if self.teams.length == 2
      self.teams.each do |team|
        team.memberships.each do |membership|
          unless user_ids.index(membership.user_id).nil?
            errors.add(:people, 'cannot contain the same user twice'[])
          end
          user_ids << membership.user_id
        end
      end
    end
  end
  
  def remove_log
    Log.clear_item_log(self.account, self)
  end

  def set_played_on_and_at
    self.played_at ||= 5.minutes.ago.utc
    self.played_on = self.played_at.to_date
  end

  def build_teams
    return if score1.blank? || score2.blank? || team1.blank? || team2.blank?

    # Create game participations first
    (@team1 + @team2).each { |user_id| game_participation_for_user(user_id) }

    # Build team 1
    team1 = teams.build(:score => score1, :account => self.account)
    @team1.each do |member|
      team1.memberships.build(:user_id => member, :game => self.game, :game_participation => game_participation_for_user(member))
    end
    team1.opponent_ids = @team2.collect(&:to_i).sort.join(',')

    # Build team 2
    team2 = teams.build(:score => score2, :account => self.account)
    @team2.each do |member|
      team2.memberships.build(:user_id => member, :game => self.game, :game_participation => game_participation_for_user(member))
    end
    team2.opponent_ids = @team1.collect(&:to_i).sort.join(',')

    self.team_one = team2.opponent_ids
    self.team_two = team1.opponent_ids
  end

  def game_participation_for_user(user_id)
    game_participation = self.game.game_participations.find_by_user_id(user_id)
    game_participation = self.game.game_participations.create(:user_id => user_id) if game_participation.nil?
    game_participation
  end
end
