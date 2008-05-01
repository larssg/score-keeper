class AddMatchesCountToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :matches_count, :integer, :default => 0
    
    Game.all.each do |game|
      game.update_attribute :matches_count, Match.count(:conditions => { :game_id => game.id })
    end
  end

  def self.down
    remove_column :games, :matches_count
  end
end
