class Game < ActiveRecord::Base
  attr_accessor :postpone_ranking_update
  
  has_many :teams
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  
  before_save :set_played_on
  after_create :update_winners
  after_create :update_rankings
  before_destroy :update_after_destroy
  after_destroy :reset_rankings_after_destroy

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
  
  def teams_from_params(teams)
    teams.each do |team_info|
      team = self.teams.build(:score => team_info[:score])
      team_info[:members].each do |member_id|
        team.memberships.build(:user_id => member_id)
      end
    end
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

  def self.reset_rankings
    User.update_all("ranking = 2000")
    Game.find(:all).each do |game|
      game.update_rankings
    end
  end
  
  def set_played_on
    self.played_on = self.played_at.to_date
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
    Game.reset_rankings unless @postpone_ranking_update
  end
  
  def title
    title = ''
    
    title << self.teams.first.display_names.join(' - ')
    title << " (#{self.teams.first.score} - #{self.teams.last.score}) "
    title << self.teams.last.display_names.join(' - ')
    
    title
  end
  
  def self.goals_scored
    User.sum(:goals_for) / 2
  end
end