class AddTimeZoneToAccountsAndUsers < ActiveRecord::Migration
  def self.up
    add_column :accounts, :time_zone, :string, :default => 'Copenhagen'
    add_column :users, :time_zone, :string

    User.reset_column_information
    Account.reset_column_information

    User.all.each do |user|
      user.update_attribute :time_zone, 'Copenhagen'
    end
  end

  def self.down
    remove_column :accounts, :time_zone
    remove_column :users, :time_zone
  end
end
