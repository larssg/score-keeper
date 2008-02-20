class RemoveOpenIds < ActiveRecord::Migration
  def self.up
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
    drop_table :open_id_authentication_settings
    drop_table :user_openids
  end

  def self.down
    create_table "user_openids", :force => true do |t|
      t.string   "openid_url", :default => "", :null => false
      t.integer  "user_id",                    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "user_openids", ["openid_url"], :name => "index_user_openids_on_openid_url", :unique => true
    add_index "user_openids", ["user_id"], :name => "index_user_openids_on_user_id"
    
    create_table "open_id_authentication_settings", :force => true do |t|
      t.string "setting"
      t.binary "value"
    end
    
    create_table "open_id_authentication_nonces", :force => true do |t|
      t.string  "nonce"
      t.integer "created"
    end
    
    create_table "open_id_authentication_associations", :force => true do |t|
      t.binary  "server_url"
      t.string  "handle"
      t.binary  "secret"
      t.integer "issued"
      t.integer "lifetime"
      t.string  "assoc_type"
    end
  end
end
