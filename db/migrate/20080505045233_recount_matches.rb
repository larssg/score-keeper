class RecountMatches < ActiveRecord::Migration
  def self.up
    Game.all.each do |game|
      game.update_attribute :matches_count, Match.count(:conditions => ['game_id = ?', game.id])
    end
  end

  def self.down
  end
end
