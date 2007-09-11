# == Schema Information
# Schema version: 8
#
# Table name: games
#
#  id         :integer(11)   not null, primary key
#  played_at  :datetime      
#  created_at :datetime      
#  updated_at :datetime      
#

# == Schema Information
# Schema version: 5
#
# Table name: games
#
#  id         :integer       not null, primary key
#  played_at  :datetime      
#  created_at :datetime      
#  updated_at :datetime      
#

class Game < ActiveRecord::Base
  has_many :teams
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  
  after_create :update_winners
  before_destroy :update_after_destroy

  def self.find_recent(how_many = 5)
    find(:all, :order => 'played_at DESC', :limit => how_many)
  end
  
  def winner
    @winner ||= self.teams.first.score > self.teams.last.score ? self.teams.first : self.teams.last 
  end
  
  protected
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
        
        person.decrement(:games_won) if team = self.winner
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
end
