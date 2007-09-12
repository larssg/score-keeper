class AddRankingToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :ranking, :integer, :default => 2000
  end

  def self.down
    remove_column :people, :ranking
  end
end