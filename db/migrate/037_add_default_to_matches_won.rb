class AddDefaultToMatchesWon < ActiveRecord::Migration
  def self.up
    # rename_column doesn't take defaults with it so
    # we need to fix that...    
    rename_column :users, :matches_won, :games_won
    add_column :users, :matches_won, :integer, :default => 0
    User.find(:all).each do |user|
      user.update_attribute :matches_won, user.games_won
    end
    remove_column :users, :games_won
  end

  def self.down
    throw "Can't rollback"
  end
end
