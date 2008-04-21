class AddPlayerRolesToGames < ActiveRecord::Migration
  def self.up
    add_column :games, :player_roles, :string
  end

  def self.down
    remove_column :games, :player_roles
  end
end
