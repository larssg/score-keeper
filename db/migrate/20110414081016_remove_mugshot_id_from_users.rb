class RemoveMugshotIdFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :mugshot_id
  end

  def self.down
    add_column :users, :mugshot_id, :integer
  end
end
