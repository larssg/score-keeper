class RenameGameIdFieldsToMatchId < ActiveRecord::Migration
  def self.up
    rename_column :comments, :game_id, :match_id
    rename_column :teams, :game_id, :match_id
  end

  def self.down
    rename_column :comments, :match_id, :game_id
    rename_column :teams, :match_id, :game_id
  end
end
