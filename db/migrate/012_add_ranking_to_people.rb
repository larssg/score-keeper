class AddRankingToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :ranking, :integer, :default => 2000
    Game.reset_rankings
  end

  def self.down
    remove_column :people, :ranking
  end
end