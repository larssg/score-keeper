class AddGameParticipationToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :game_participation_id, :integer
    add_index :memberships, :game_participation_id

    Membership.reset_column_information
    
    Account.all.each do |account|
      game = account.games.first
      account.users.each do |user|
        game_participation = game.game_participations.find(:first, :conditions => { :user_id => user.id })
        user.memberships.update_all("game_participation_id = #{game_participation.id}")
      end
    end
  end

  def self.down
    remove_column :memberships, :game_participation_id
  end
end
