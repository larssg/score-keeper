class AddPositionIdsToMatches < ActiveRecord::Migration
  def self.up
    add_column :matches, :position_ids, :string
  end

  def self.down
    remove_column :matches, :position_ids
  end
end
