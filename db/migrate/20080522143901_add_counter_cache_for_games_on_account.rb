class AddCounterCacheForGamesOnAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :games_count, :integer, :default => 0
    
    Account.all.each do |account|
      account.update_attribute :games_count, Game.count(:conditions => { :account_id => account.id })
    end
  end

  def self.down
    remove_column :accounts, :games_count
  end
end
