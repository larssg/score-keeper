class RenameGamesToMatches < ActiveRecord::Migration
  def self.up
    rename_table :games, :matches
    rename_column :users, :games_won, :matches_won
  end

  def self.down
    rename_table :matches, :games
    rename_column :users, :matches_won, :games_won
  end
end
