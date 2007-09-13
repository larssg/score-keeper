class AddTeamIdsToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :team_ids, :string
    add_column :teams, :won, :boolean, :default => false
    add_index :teams, :team_ids
    
    Team.find(:all).each do |team|
      team.save # Will call ::update_cache_values
    end
  end

  def self.down
    remove_index :teams, :team_ids
    remove_column :teams, :team_ids
    remove_column :teams, :won
  end
end