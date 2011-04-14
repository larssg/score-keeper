class AddIndexOnUsersFeedToken < ActiveRecord::Migration
  def self.up
    add_index :users, :feed_token
  end

  def self.down
    remove_index :users, :feed_token
  end
end