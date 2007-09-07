class AddGamesWonAndGoalCountToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :games_won, :integer, :default => 0
    add_column :people, :goals_for, :integer, :default => 0
    add_column :people, :goals_against, :integer, :default => 0
    
    Game.find(:all).each do |game|
      game.send :update_winners
    end
  end

  def self.down
    remove_column :people, :games_won
    remove_column :people, :goals_for
    remove_column :people, :goals_against
  end
end