class MovePeopleToUsers < ActiveRecord::Migration
  class Person < ActiveRecord::Base; end

  def self.up
    add_column :users, :display_name, :string
    add_column :users, :memberships_count, :integer, :default => 0
    add_column :users, :games_won, :integer, :default => 0
    add_column :users, :goals_for, :integer, :default => 0
    add_column :users, :goals_against, :integer, :default => 0
    add_column :users, :mugshot_id, :integer
    add_column :users, :ranking, :integer, :default => 2000
    
    Person.find(:all).each do |person|
      login = person.display_name.downcase.gsub(' ', '')
      
      User.create!(
        :login => login,
        :email => login + '@example.com',
        :password => login,
        :password_confirmation => login,
        :display_name => person.display_name,
        :memberships_count => person.memberships_count,
        :games_won => person.games_won,
        :goals_for => person.goals_for,
        :goals_against => person.goals_against,
        :mugshot_id => person.mugshot_id,
        :ranking => person.ranking,
        :name => [person.first_name, person.last_name].compact.join(' ')
      )
    end
    
    drop_table :people
    rename_column :memberships, :person_id, :user_id
  end

  def self.down
    remove_column :users, :display_name
    remove_column :users, :memberships_count
    remove_column :users, :games_won
    remove_column :users, :goals_for
    remove_column :users, :goals_against
    remove_column :users, :mugshot_id
    remove_column :users, :ranking
    
    create_table "people", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "display_name"
      t.integer  "memberships_count"
      t.integer  "games_won",         :default => 0
      t.integer  "goals_for",         :default => 0
      t.integer  "goals_against",     :default => 0
      t.integer  "mugshot_id"
      t.integer  "ranking",           :default => 2000
      t.integer  "new_ranking",       :default => 0
    end
    rename_column :memberships, :user_id, :person_id
  end
end