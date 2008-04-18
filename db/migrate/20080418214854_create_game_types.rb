class CreateGameTypes < ActiveRecord::Migration
  def self.up
    create_table :games, :force => true do |t|
      t.references :account
      t.string :name
      t.integer :team_size, :default => 1
      t.text :rules
      t.timestamps
    end
    add_index :games, :account_id
    
    add_column :matches, :game_id, :integer
    add_index :matches, :game_id
    
    Account.all.each do |account|
      game = account.games.create(:name => 'Foosball', :team_size => 2)
      account.matches.update_all("game_id = #{game.id}")
    end
  end

  def self.down
    drop_table :game_participations
    remove_column :matches, :game_id
    drop_table :games
  end
end
