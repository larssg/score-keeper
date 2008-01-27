class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  def self.all_time_high
    Membership.find(:first, :order => 'memberships.current_ranking DESC')
  end
  
  def self.all_time_low
    Membership.find(:first, :order => 'memberships.current_ranking')
  end
  
  def self.find_team(user_ids)
    Membership.find(:all,
      :conditions => { :user_id => user_ids },
      :order => 'memberships.created_at',
      :select => 'memberships.user_id, memberships.current_ranking, teams.game_id AS game_id, memberships.created_at, games.played_at AS played_at',
      :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN games ON teams.game_id = games.id')
  end
end