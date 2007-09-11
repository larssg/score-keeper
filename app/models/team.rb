class Team < ActiveRecord::Base
  has_many :memberships
  belongs_to :game
  
  def other
    self.game.teams.select { |team| team.id != self.id }.first
  end
end
