class CreateUserOpenids < ActiveRecord::Migration
  def self.up
    create_table :user_openids do |t|
      t.column      :openid_url, :string,  :null => false
      t.column      :user_id,    :integer, :null => false
      t.column      :created_at, :datetime
      t.column      :updated_at, :datetime
    end

    add_index "user_openids", ["openid_url"], :name => "index_user_openids_on_openid_url", :unique => true
    add_index "user_openids", ["user_id"], :name => "index_user_openids_on_user_id"
  end

  def self.down
    remove_index :user_openids, :column => :openid_url
    remove_index :unique, :name => :user_ids_on_user_openids_table
    drop_table :user_openids
  end
end
