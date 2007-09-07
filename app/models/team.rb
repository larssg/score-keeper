# == Schema Information
# Schema version: 8
#
# Table name: teams
#
#  id         :integer(11)   not null, primary key
#  game_id    :integer(11)   
#  score      :integer(11)   
#  created_at :datetime      
#  updated_at :datetime      
#

# == Schema Information
# Schema version: 5
#
# Table name: teams
#
#  id         :integer       not null, primary key
#  game_id    :integer       
#  score      :integer       
#  created_at :datetime      
#  updated_at :datetime      
#

class Team < ActiveRecord::Base
  has_many :memberships
  belongs_to :game
  
  def other
    self.game.teams.select { |team| team.id != self.id }.first
  end
end
