class AddMissingGameIdOnLogs < ActiveRecord::Migration
  def self.up
    Log.all.each do |log|
      if log.linked_model == 'Match'
        log.update_attribute :game_id, Match.find(log.linked_id).game_id
      elsif log.linked_model == 'Comment'
        log.update_attribute :game_id, Comment.find(log.linked_id).match.game_id
      end
    end
  end

  def self.down
  end
end
