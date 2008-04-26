class SwitchGameParticipationIdToGameIds < ActiveRecord::Migration
  def self.up
    remove_column :users, :cache_game_participation_ids
    add_column :users, :cache_game_ids, :string
    
    User.all.each do |user|
      user.update_attribute :cache_game_ids, user.game_participations.collect(&:game_id).join(',')
    end
  end

  def self.down
    remove_column :users, :cache_game_ids
    add_column :users, :cache_game_participation_ids, :string
  end
end
