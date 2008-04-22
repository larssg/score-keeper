class AddGameIdToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :game_id, :integer
    add_index :memberships, :game_id
    
    Membership.reset_column_information
    
    Account.all.each do |account|
      game = account.games.first
      account.users.each do |user|
        user.memberships.update_all("game_id = #{game.id}")
      end
    end
  end

  def self.down
    remove_column :memberships, :game_id
  end
end
