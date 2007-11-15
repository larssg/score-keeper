class AddIndexToMembershipsPerson < ActiveRecord::Migration
  def self.up
    add_index :memberships, :person_id
  end

  def self.down
    remove_index :memberships, :person_id
  end
end
