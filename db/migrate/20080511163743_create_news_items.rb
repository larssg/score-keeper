class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.string :uid
      t.string :name
      t.text :content
      t.string :url
      t.datetime :posted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :news_items
  end
end
