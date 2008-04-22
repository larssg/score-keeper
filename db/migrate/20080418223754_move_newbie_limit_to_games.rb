class MoveNewbieLimitToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :newbie_limit, :integer, :default => 20
    
    Game.reset_column_information
    
    Account.all.each do |account|
      account.games.first.update_attribute :newbie_limit, account.newbie_limit
    end
    
    remove_column :accounts, :newbie_limit
  end

  def self.down
    add_column :accounts, :newbie_limit, :integer, :default => 20
    remove_column :games, :newbie_limit
  end
end
