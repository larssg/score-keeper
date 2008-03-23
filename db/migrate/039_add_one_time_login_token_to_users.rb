class AddOneTimeLoginTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :login_token, :string
  end

  def self.down
    remove_column :users, :login_token
  end
end
