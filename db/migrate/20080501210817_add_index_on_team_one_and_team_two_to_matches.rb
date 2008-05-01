class AddIndexOnTeamOneAndTeamTwoToMatches < ActiveRecord::Migration
  def self.up
    add_index :matches, :team_one
    add_index :matches, :team_two
  end

  def self.down
    remove_index :matches, :team_two
    remove_index :matches, :team_one
  end
end
