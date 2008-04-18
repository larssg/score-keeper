class RenameGamesPlayedToMatchesPlayed < ActiveRecord::Migration
  def self.up
    rename_column :game_participations, :games_played, :matches_played
  end

  def self.down
    rename_column :game_participations, :matches_played, :games_played
  end
end
