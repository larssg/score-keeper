class AddNewRankingToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :new_ranking, :integer, :default => 0
  end

  def self.down
    remove_column :people, :new_ranking
  end
end
