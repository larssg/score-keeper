class AddPointsAwardedToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :points_awarded, :integer
    Game.reset_rankings
  end

  def self.down
    remove_column :memberships, :points_awarded
  end
end