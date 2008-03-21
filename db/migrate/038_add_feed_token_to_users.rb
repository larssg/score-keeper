class AddFeedTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :feed_token, :string
    
    User.find(:all).each do |user|
      user.set_feed_token
    end
  end

  def self.down
    remove_column :users, :feed_token
  end
end