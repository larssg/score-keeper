class AddLastGameIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_game_id, :integer
  end

  def self.down
    remove_column :users, :last_game_id
  end
end
