class AddOpponentToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :opponent_ids, :string
    
    # Add opponent_ids to all existing data
    Team.find(:all).each do |team|
      team.update_attribute :opponent_ids, team.other.team_ids
    end

    add_index :teams, :opponent_ids
  end

  def self.down
    remove_index :teams, :opponent_ids
    remove_column :teams, :opponent_ids
  end
end
