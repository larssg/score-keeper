class AddTeamCacheToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :team_one, :string
    add_column :games, :team_two, :string
    
    Game.find(:all).each do |game|
      if game.teams.count == 2
        game.teams.first.update_team_cache_on_game
      end
    end
  end

  def self.down
    remove_column :games, :team_one
    remove_column :games, :team_two
  end
end
