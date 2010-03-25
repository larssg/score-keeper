class AddLockedToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :locked, :boolean, :default => false
  end

  def self.down
    remove_column :games, :locked
  end
end
