class Match < ActiveRecord::Base
  attr_accessor :postpone_ranking_update

  # Virtual attributes for match info
  attr_accessor :score1, :user11, :user12
  attr_accessor :score2, :user21, :user22

  attr_accessor :filter

  belongs_to :account
  has_many :teams
  has_many :comments
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  
  before_save :set_played_on_and_at
  before_validation_on_create :build_teams
  after_create :update_winners
  after_create :update_rankings
  after_create :update_positions
  after_create :log
  before_destroy :update_after_destroy
  after_destroy :reset_rankings_after_destroy
  after_destroy :remove_log

  validates_presence_of :team_one
  validates_presence_of :team_two

  def self.per_page
    20
  end
  
  def self.recent_options(filter, options = {})
    default_options = { :order => 'played_at DESC' }

    if filter
      if filter.index(',')
        conditions = ['team_one = ? OR team_two = ?', filter, filter]
      else
        conditions = ["team_one LIKE ? OR team_one LIKE ? OR team_two LIKE ? OR team_two LIKE ?", filter + ',%', '%,' + filter, filter + ',%', '%,' + filter]
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
    @winner ||= self.teams.first.score > self.teams.last.score ? self.teams.first : self.teams.last 
  end
  
  def loser
    @loser ||= self.winner.other
  end
  
  def positions
    self.position_ids.blank? ? nil : self.position_ids.split(',').collect(&:to_i)
  end
  
  def positions=(users)
    self.position_ids = users.collect(&:id).join(',')
  end

  def validate
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

  def self.reset_rankings(account)
    return if account.nil?
    account.users.update_all("users.ranking = 2000, users.memberships_count = 0")
    account.matches.find(:all).each do |match|
      match.update_rankings
      match.teams.each do |team|
        team.memberships.each do |membership|
          User.update_all("users.memberships_count = users.memberships_count + 1", "users.id = #{membership.user_id}")
        end
      end
      match.update_positions
    end
  end
  
  def update_rankings
    return if self.teams.count < 2
    transfer = (0.01 * self.loser.ranking_total).round
    self.loser.award_points(-1 * transfer)
    self.winner.award_points(transfer)
  end
  
  def update_winners
    self.teams.each do |team|
      team.memberships.each do |membership|
        user = membership.user

        user.increment(:matches_won) if team == self.winner
        user.goals_for += team.score
        user.goals_against += team.other.score
        user.memberships_count = Membership.count(:conditions => { :user_id => user.id })
        
        user.save
      end
      
      team.update_attribute :won, team == self.winner
    end
  end
  
  def update_positions
    self.positions = self.account.ranked_users
    # Using update_all to avoid callbacks being called
    Match.update_all("matches.position_ids = '#{self.position_ids}'", "matches.id = #{self.id}")
  end
  
  def update_after_destroy
    self.teams.each do |team|
      team.memberships.each do |membership|
        user = membership.user
        
        user.decrement(:matches_won) if team == self.winner
        user.goals_for -= team.score
        user.goals_against -= team.other.score
        user.decrement(:memberships_count)
        
        user.save
      end
    end
    
    self.teams.each do |team|
      team.memberships.each { |m| m.destroy }
      team.destroy
    end
  end
  
  def reset_rankings_after_destroy
    Match.reset_rankings(self.account) unless @postpone_ranking_update
  end
  
  def title()
    [
      self.teams.first.display_names.join(' - '),
      "(#{self.teams.first.score} - #{self.teams.last.score})",
      self.teams.last.display_names.join(' - ')
    ].join(' ')
  end

  protected
  def log
    return if self.account.blank?
    self.account.logs.create(:linked_model => self.class.class_name,
      :linked_id => self.id,
      :user => self.creator,
      :message => "#{self.winner.memberships.collect { |m| m.user.name }.join(' and ')} won #{self.winner.score} to #{self.loser.score} over #{self.loser.memberships.collect { |m| m.user.name }.join(' and ')}",
      :published_at => self.played_at)
  end
  
  def remove_log
    Log.clear_item_log(self.account, self)
  end
  
  def set_played_on_and_at
    self.played_at ||= 5.minutes.ago.utc
    self.played_on = self.played_at.to_date
  end

  def build_teams
    team1 = teams.build(:score => score1, :account => self.account)
    team1.memberships.build(:user_id => user11)
    team1.memberships.build(:user_id => user12)
    team1.opponent_ids = [user21, user22].collect { |user_id| user_id.to_i }.sort.join(',')

    team2 = teams.build(:score => score2, :account => self.account)
    team2.memberships.build(:user_id => user21)
    team2.memberships.build(:user_id => user22)
    team2.opponent_ids = [user11, user12].collect { |user_id| user_id.to_i }.sort.join(',')
    
    self.team_one = team2.opponent_ids
    self.team_two = team1.opponent_ids
  end
end