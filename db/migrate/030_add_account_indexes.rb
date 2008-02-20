class AddAccountIndexes < ActiveRecord::Migration
  def self.up
    add_index :games, :account_id
    add_index :teams, :account_id
    add_index :users, :account_id
  end

  def self.down
    remove_index :games, :account_id
    remove_index :teams, :account_id
    remove_index :users, :account_id
  end
end
