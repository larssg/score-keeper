class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :person

  def self.all_time_high
    Membership.find(:first, :order => 'memberships.current_ranking DESC')
  end
  
  def self.all_time_low
    Membership.find(:first, :order => 'memberships.current_ranking')
  end
  
  def self.find_team(person_ids)
    Membership.find(:all,
      :conditions => { :person_id => person_ids },
      :order => 'memberships.created_at',
      :select => 'memberships.person_id, memberships.current_ranking, teams.game_id AS game_id, memberships.created_at',
      :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id')
  end
end