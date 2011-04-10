class RemoveMugshots < ActiveRecord::Migration
  def self.up
    drop_table :mugshots
  end

  def self.down
    create_table "mugshots", :force => true do |t|
      t.integer  "size"
      t.string   "content_type"
      t.string   "filename"
      t.integer  "height"
      t.integer  "width"
      t.integer  "parent_id"
      t.string   "thumbnail"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
