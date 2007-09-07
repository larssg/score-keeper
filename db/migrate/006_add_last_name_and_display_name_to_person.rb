class AddLastNameAndDisplayNameToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :first_name, :string
    add_column :people, :last_name, :string
    add_column :people, :display_name, :string
    
    Person.find(:all).each do |person|
      person.update_attribute :first_name, person.name
    end
    
    remove_column :people, :name
  end

  def self.down
    add_column :people, :name, :string
    
    Person.find(:all).each do |person|
      person.update_attribute :name, person.full_name
    end
    
    remove_column :people, :first_name
    remove_column :people, :last_name
    remove_column :people, :display_name
  end
end
