class GameParticipation < ActiveRecord::Base
  belongs_to :game
  belongs_to :user
  
  def matches_lost
    matches_played - matches_won
  end

  def winning_percentage
    return 0.0 if matches_played == 0
    ((matches_won.to_f / matches_played.to_f) * 1000).to_i / 10.to_f
  end
  
  def difference
    points_for - points_against
  end
  
  def difference_average
    return 0.0 if matches_played == 0
    ((10 * difference) / matches_played) / 10.0
  end
end
