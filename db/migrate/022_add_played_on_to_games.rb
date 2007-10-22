class AddPlayedOnToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :played_on, :datetime
    add_index :games, :played_on
    
    Game.find(:all).each do |game|
      game.update_attribute :played_on, game.played_at.to_date
    end
  end

  def self.down
    remove_index :games, :played_on
    remove_column :games, :played_on
  end
end
