class Membership < ActiveRecord::Base
  belongs_to :game
  belongs_to :team
  belongs_to :user
  belongs_to :game_participation

  def self.all_time_high(game)
    game.memberships.order('memberships.current_ranking DESC').first
  end

  def self.all_time_low(game)
    game.memberships.order('memberships.current_ranking').first
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
