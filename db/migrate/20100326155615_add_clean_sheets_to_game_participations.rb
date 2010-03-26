class AddCleanSheetsToGameParticipations < ActiveRecord::Migration
  def self.up
    add_column :game_participations, :clean_sheets, :integer, :default => 0
    
    Team.find_each(:conditions => 'score = 0') do |team|
      team.other.memberships.each do |membership|
        membership.game_participation.increment!(:clean_sheets)
      end
    end
  end

  def self.down
    remove_column :game_participations, :clean_sheets
  end
end
