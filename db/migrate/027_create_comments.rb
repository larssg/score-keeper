class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :user
      t.references :game
      t.text :body
      t.timestamps
    end
    
    add_column :games, :comments_count, :integer, :default => 0
    add_column :users, :comments_count, :integer, :default => 0
    
    add_index :comments, :user_id
    add_index :comments, :game_id
  end

  def self.down
    remove_column :users, :comments_count
    remove_column :games, :comments_count
    drop_table :comments
  end
end
