class AddCleanSheetsToGameParticipations < ActiveRecord::Migration
  def self.up
    add_column :game_participations, :clean_sheets, :integer, :default => 0
    
    Team.all.each do |team|
      if team.other.score == 0
        team.memberships.each do |membership|
          membership.game_participation.increment!(:clean_sheets)
        end
      end
    end
  end

  def self.down
    remove_column :game_participations, :clean_sheets
  end
end
