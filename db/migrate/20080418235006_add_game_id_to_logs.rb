class AddGameIdToLogs < ActiveRecord::Migration
  def self.up
    add_column :logs, :game_id, :integer
    add_index :logs, :game_id
    
    Account.all.each do |account|
      game = account.games.first
      account.logs.update_all("game_id = #{game.id}")
    end
  end

  def self.down
    remove_column :logs, :game_id
  end
end
