class AddCreatorToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :creator_id, :integer
  end

  def self.down
    remove_column :games, :creator
  end
end
