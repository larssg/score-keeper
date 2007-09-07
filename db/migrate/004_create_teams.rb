class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.integer :game_id
      t.integer :score
      t.timestamps
    end
    
    remove_column :games, :score_team_one
    remove_column :games, :score_team_two
    remove_column :games, :team_one_id
    remove_column :games, :team_two_id
  end

  def self.down
    drop_table :teams
    
    add_column :games, :score_team_one, :integer
    add_column :games, :score_team_two, :integer
    add_column :games, :team_one_id, :integer
    add_column :games, :team_two_id, :integer
  end
end
