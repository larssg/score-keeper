class CreateGameParticipations < ActiveRecord::Migration
  def self.up
    create_table :game_participations do |t|
      t.references :user
      t.references :game
      t.integer :ranking, :default => 2000
      t.integer :points_for, :default => 0
      t.integer :points_against, :default => 0
      t.integer :matches_won, :default => 0
      t.timestamps
    end
    
    Account.all.each do |account|
      game = account.games.first
      account.users.each do |user|
        GameParticipation.create(
          :user => user,
          :game => game,
          :ranking => user.ranking,
          :points_for => user.goals_for,
          :points_against => user.goals_against,
          :matches_won => user.matches_won)
      end
    end
    
    remove_column :users, :ranking
    remove_column :users, :goals_for
    remove_column :users, :goals_against
    remove_column :users, :matches_won
  end

  def self.down
    add_column :users, :ranking, :integer, :default => 2000
    add_column :users, :goals_for, :integer, :default => 0
    add_column :users, :goals_against, :integer, :default => 0
    add_column :users, :matches_won, :integer, :default => 0
    drop_table :game_participations
  end
end