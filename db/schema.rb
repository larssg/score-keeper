# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 27) do

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"
  add_index "comments", ["game_id"], :name => "index_comments_on_game_id"

  create_table "games", :force => true do |t|
    t.datetime "played_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "team_one"
    t.string   "team_two"
    t.datetime "played_on"
    t.integer  "comments_count", :default => 0
  end

  add_index "games", ["played_on"], :name => "index_games_on_played_on"

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points_awarded"
    t.integer  "current_ranking"
  end

  add_index "memberships", ["user_id"], :name => "index_memberships_on_person_id"
  add_index "memberships", ["team_id"], :name => "index_memberships_on_team_id"

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

  create_table "open_id_authentication_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.string  "nonce"
    t.integer "created"
  end

  create_table "open_id_authentication_settings", :force => true do |t|
    t.string "setting"
    t.binary "value"
  end

  create_table "teams", :force => true do |t|
    t.integer  "game_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "team_ids"
    t.boolean  "won",          :default => false
    t.string   "opponent_ids"
  end

  add_index "teams", ["team_ids"], :name => "index_teams_on_team_ids"
  add_index "teams", ["opponent_ids"], :name => "index_teams_on_opponent_ids"

  create_table "user_openids", :force => true do |t|
    t.string   "openid_url", :default => "", :null => false
    t.integer  "user_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_openids", ["openid_url"], :name => "index_user_openids_on_openid_url", :unique => true
  add_index "user_openids", ["user_id"], :name => "index_user_openids_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.boolean  "is_admin",                                :default => false
    t.string   "name"
    t.string   "display_name"
    t.integer  "memberships_count",                       :default => 0
    t.integer  "games_won",                               :default => 0
    t.integer  "goals_for",                               :default => 0
    t.integer  "goals_against",                           :default => 0
    t.integer  "mugshot_id"
    t.integer  "ranking",                                 :default => 2000
    t.integer  "comments_count",                          :default => 0
  end

end
