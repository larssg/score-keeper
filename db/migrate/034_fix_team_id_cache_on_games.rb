class FixTeamIdCacheOnGames < ActiveRecord::Migration
  def self.up
    Game.find(:all).each do |game|
      game.team_one = game.teams.first.memberships.collect { |m| m.user_id }.sort.join(',')
      game.team_two = game.teams.last.memberships.collect { |m| m.user_id }.sort.join(',')
      game.save!
    end
  end

  def self.down
  end
end
