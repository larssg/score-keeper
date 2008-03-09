class AddNewbieLimitToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :newbie_limit, :integer, :default => 20
  end

  def self.down
    remove_column :accounts, :newbie_limit
  end
end
