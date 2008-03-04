class Game < ActiveRecord::Base
  attr_accessor :postpone_ranking_update

  # Virtual attributes for game info
  attr_accessor :score1, :user11, :user12
  attr_accessor :score2, :user21, :user22

  belongs_to :account
  has_many :teams
  has_many :comments
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  
  before_save :set_played_on_and_at
  before_validation_on_create :build_teams
  after_create :update_winners
  after_create :update_rankings
  before_destroy :update_after_destroy
  after_destroy :reset_rankings_after_destroy

  validates_presence_of :team_one
  validates_presence_of :team_two

  def self.per_page
    20
  end
  
  def self.find_recent(options = {})
    default_options = { :order => 'played_at DESC' }
    find(:all, default_options.merge(options))
  end
  
  def winner
    @winner ||= self.teams.first.score > self.teams.last.score ? self.teams.first : self.teams.last 
  end
  
  def loser
    @loser ||= self.winner.other
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
    account.users.update_all("ranking = 2000")
    account.games.find(:all).each do |game|
      game.update_rankings
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

        user.increment(:games_won) if team == self.winner
        user.goals_for += team.score
        user.goals_against += team.other.score
        user.memberships_count = Membership.count(:conditions => { :user_id => user.id })
        
        user.save
      end
      
      team.update_attribute :won, team == self.winner
    end
  end
  
  def update_after_destroy
    self.teams.each do |team|
      team.memberships.each do |membership|
        user = membership.user
        
        user.decrement(:games_won) if team == self.winner
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
    Game.reset_rankings(self.account) unless @postpone_ranking_update
  end
  
  def title()
    [
      self.teams.first.display_names.join(' - '),
      "(#{self.teams.first.score} - #{self.teams.last.score})",
      self.teams.last.display_names.join(' - ')
    ].join(' ')
  end

  protected
  def set_played_on_and_at
    self.played_at ||= 5.minutes.ago
    self.played_on = self.played_at.to_date
  end

  def build_teams
    team1 = teams.build(:score => score1, :account => self.account)
    team1.memberships.build(:user_id => user11)
    team1.memberships.build(:user_id => user12)
    team1.opponent_ids = [user21, user22].collect { |user_id| user_id.to_i }.sort.join(',')
    self.team_one = team1

    team2 = teams.build(:score => score2, :account => self.account)
    team2.memberships.build(:user_id => user21)
    team2.memberships.build(:user_id => user22)
    team2.opponent_ids = [user11, user12].collect { |user_id| user_id.to_i }.sort.join(',')
    self.team_two = team2
  end
end