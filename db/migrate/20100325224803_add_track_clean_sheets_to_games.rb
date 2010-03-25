class AddTrackCleanSheetsToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :track_clean_sheets, :boolean, :default => false
  end

  def self.down
    remove_column :games, :track_clean_sheets
  end
end
