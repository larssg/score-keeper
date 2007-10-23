class AddCurrentRankingToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :current_ranking, :integer
    Game.reset_rankings
  end

  def self.down
    remove_column :memberships, :current_ranking
  end
end
