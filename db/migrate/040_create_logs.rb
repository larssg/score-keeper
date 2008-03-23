class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.references :account
      t.references :user
      t.string :linked_model
      t.integer :linked_id
      t.text :message
      t.datetime :published_at
      t.timestamps
    end
    
    add_index :logs, :account_id
    add_index :logs, :published_at
  end

  def self.down
    drop_table :logs
  end
end
