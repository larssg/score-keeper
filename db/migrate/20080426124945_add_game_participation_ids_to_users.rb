class AddGameParticipationIdsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :cache_game_participation_ids, :string
    
    User.all.each do |user|
      user.update_attribute :cache_game_participation_ids, user.game_participations.collect(&:id).join(',')
    end
  end

  def self.down
    remove_column :users, :cache_game_participation_ids
  end
end
