class RenameGamesToMatches < ActiveRecord::Migration
  def self.up
    rename_table :games, :matches
    rename_column :users, :games_won, :matches_won
    rename_column :users, :games_lost, :matches_lost
  end

  def self.down
    rename_table :matches, :games
    rename_column :users, :matches_won, :games_won
    rename_column :users, :matches_lost, :games_lost
  end
end
