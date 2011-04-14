class AddIndexOnAccountsDomain < ActiveRecord::Migration
  def self.up
    add_index :accounts, :domain
  end

  def self.down
    remove_index :accounts, :domain
  end
end