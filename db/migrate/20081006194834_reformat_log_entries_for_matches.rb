class ReformatLogEntriesForMatches < ActiveRecord::Migration
  def self.up
    Match.all.each do |match|
      Log.clear_item_log(match.account, match)
      match.log
    end
  end

  def self.down
  end
end
