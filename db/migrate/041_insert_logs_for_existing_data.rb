class InsertLogsForExistingData < ActiveRecord::Migration
  def self.up
    Log.delete_all
    
    Match.find(:all).each { |match| match.send :log }
    Comment.find(:all).each { |comment| comment.send :log }
  end

  def self.down
  end
end
