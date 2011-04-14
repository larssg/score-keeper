class AddIndexOnMembershipsTeamId < ActiveRecord::Migration
  def self.up
    add_index :memberships, :team_id
  end

  def self.down
    remove_index :memberships, :team_id
  end
end