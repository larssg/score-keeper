class MoveMembershipsCountToGameParticipations < ActiveRecord::Migration
  def self.up
    add_column :game_participations, :games_played, :integer, :default => 0
    
    GameParticipation.reset_column_information
    
    Account.all.each do |account|
      account.users.each do |user|
        if user.memberships_count > 0
          user.game_participations.first.update_attribute :games_played, user.memberships_count
        end
      end
    end
    
    remove_column :users, :memberships_count
  end

  def self.down
    add_column :users, :memberships_count, :integer, :default => 0
    remove_column :game_participations, :games_played
  end
end
