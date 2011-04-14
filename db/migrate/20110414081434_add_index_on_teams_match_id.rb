class AddIndexOnTeamsMatchId < ActiveRecord::Migration
  def self.up
    add_index :teams, :match_id
  end

  def self.down
    remove_index :teams, :match_id
  end
end