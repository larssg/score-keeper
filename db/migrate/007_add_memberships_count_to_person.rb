class AddMembershipsCountToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :memberships_count, :integer, :default => 0
    
    Person.find(:all).each do |person|
      person.update_attribute :memberships_count, person.memberships.count
    end
  end

  def self.down
    remove_column :people, :memberships_count
  end
end