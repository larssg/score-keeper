class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  def self.all_time_high(game)
    Membership.find(:first,
      :order => 'memberships.current_ranking DESC',
      :conditions => [ 'matches.game_id = ? AND memberships.user_id IN (?)', game.id, game.account.enabled_user_ids ],
      :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id')
  end
  
  def self.all_time_low(game)
    Membership.find(:first,
      :order => 'memberships.current_ranking',
      :conditions => [ 'matches.game_id = ? AND memberships.user_id IN (?)', game.id, game.account.enabled_user_ids ],
      :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id')
  end
  
  def self.find_team(user_ids, from, account)
    @users = account.users.find(:all, :conditions => { :id => user_ids })
    @memberships = Membership.find(:all,
      :conditions => ['memberships.user_id IN (?) AND matches.played_at >= ?', @users.collect { |u| u.id }, from],
      :order => 'memberships.created_at',
      :select => 'memberships.user_id, memberships.current_ranking, teams.match_id AS match_id, memberships.created_at, matches.played_at AS played_at',
      :joins => 'LEFT JOIN teams ON memberships.team_id = teams.id LEFT JOIN matches ON teams.match_id = matches.id')
  end
end