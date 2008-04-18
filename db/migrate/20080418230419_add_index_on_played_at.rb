class AddIndexOnPlayedAt < ActiveRecord::Migration
  def self.up
    add_index :matches, :played_at
  end

  def self.down
    remove_index :matches, :played_at
  end
end
