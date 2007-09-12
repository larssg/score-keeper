class Game < ActiveRecord::Base
  has_many :teams
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  
  after_create :update_winners
  after_create :update_rankings
  before_destroy :update_after_destroy
  after_destroy :reset_rankings_after_destroy

  def self.find_recent(options = {})
    default_options = { :order => 'played_at DESC', :limit => 5 }
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
      team = self.teams.create(:score => team_info[:score])
      team_info[:members].each do |member_id|
        team.memberships.create(:person_id => member_id)
      end
    end
  end
  
  def validate
    person_ids = []
    
    if self.teams.length == 2
      self.teams.each do |team|
        team.memberships.each do |membership|
          unless person_ids.index(membership.person_id).nil?
            errors.add(:people, 'cannot contain the same person twice'[])
          end
          person_ids << membership.person_id
        end
      end
    end
  end

  def self.reset_rankings
    Person.update_all("ranking = 2000")
    Game.find(:all).each do |game|
      game.update_rankings
    end
  end

  def update_rankings
    transfer = (0.01 * self.loser.ranking_total).round
    self.loser.award_points(-1 * transfer)
    self.winner.award_points(transfer)
  end
  
  def update_winners
    self.teams.each do |team|
      team.memberships.each do |membership|
        person = membership.person

        person.increment(:games_won) if team == self.winner
        person.goals_for += team.score
        person.goals_against += team.other.score
        
        person.save
      end
    end
  end
  
  def update_after_destroy
    self.teams.each do |team|
      team.memberships.each do |membership|
        person = membership.person
        
        person.decrement(:games_won) if team == self.winner
        person.goals_for -= team.score
        person.goals_against -= team.other.score
        
        person.save
      end
    end
    
    self.teams.each do |team|
      team.memberships.each { |m| m.destroy }
      team.destroy
    end
  end
  
  def reset_rankings_after_destroy
    Game.reset_rankings
  end
end
