class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.datetime :played_at
      t.integer :score_team_one
      t.integer :score_team_two
      t.integer :team_one_id
      t.integer :team_two_id
      t.timestamps 
    end
  end

  def self.down
    drop_table :games
  end
end
