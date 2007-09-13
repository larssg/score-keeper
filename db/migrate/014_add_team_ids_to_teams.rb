class AddTeamIdsToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :team_ids, :string
    add_index :teams, :team_ids
    
    Team.find(:all).each do |team|
      team.update_attribute :team_ids, team.memberships.collect{|m| m.person_id}.sort.join(',')
    end
  end

  def self.down
    remove_index :teams, :team_ids
    remove_column :teams, :team_ids
  end
end