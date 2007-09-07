class CreateMugshots < ActiveRecord::Migration
  def self.up
    create_table :mugshots do |t|
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string :thumbnail
      t.timestamps 
    end
    
    add_column :people, :mugshot_id, :integer
  end

  def self.down
    remove_column :people, :mugshot_id
    drop_table :mugshots
  end
end
