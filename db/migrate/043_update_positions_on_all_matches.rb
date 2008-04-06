class UpdatePositionsOnAllMatches < ActiveRecord::Migration
  def self.up
    Account.find(:all).each do |account|
      say "Updating rankings for account #{account.name}"
      Match.reset_rankings account
    end
  end

  def self.down
  end
end
