# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110414081016) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",   :default => "Copenhagen"
    t.integer  "games_count", :default => 0
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "match_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["match_id"], :name => "index_comments_on_game_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "game_participations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "ranking",        :default => 2000
    t.integer  "points_for",     :default => 0
    t.integer  "points_against", :default => 0
    t.integer  "matches_won",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "matches_played"
    t.integer  "clean_sheets",   :default => 0
  end

  create_table "games", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.integer  "team_size",          :default => 1
    t.text     "rules"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "newbie_limit",       :default => 20
    t.string   "player_roles"
    t.integer  "matches_count",      :default => 0
    t.boolean  "locked",             :default => false
    t.boolean  "track_clean_sheets", :default => false
  end

  add_index "games", ["account_id"], :name => "index_games_on_account_id"

  create_table "logs", :force => true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "linked_model"
    t.integer  "linked_id"
    t.text     "message"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "game_id"
  end

  add_index "logs", ["account_id"], :name => "index_logs_on_account_id"
  add_index "logs", ["game_id"], :name => "index_logs_on_game_id"
  add_index "logs", ["published_at"], :name => "index_logs_on_published_at"

  create_table "matches", :force => true do |t|
    t.datetime "played_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.string   "team_one"
    t.string   "team_two"
    t.datetime "played_on"
    t.integer  "comments_count", :default => 0
    t.integer  "account_id"
    t.string   "position_ids"
    t.integer  "game_id"
  end

  add_index "matches", ["account_id"], :name => "index_games_on_account_id"
  add_index "matches", ["game_id"], :name => "index_matches_on_game_id"
  add_index "matches", ["played_at"], :name => "index_matches_on_played_at"
  add_index "matches", ["played_on"], :name => "index_games_on_played_on"
  add_index "matches", ["team_one"], :name => "index_matches_on_team_one"
  add_index "matches", ["team_two"], :name => "index_matches_on_team_two"

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points_awarded"
    t.integer  "current_ranking"
    t.integer  "game_id"
    t.integer  "game_participation_id"
  end

  add_index "memberships", ["game_id"], :name => "index_memberships_on_game_id"
  add_index "memberships", ["game_participation_id"], :name => "index_memberships_on_game_participation_id"
  add_index "memberships", ["user_id"], :name => "index_memberships_on_person_id"

  create_table "news_items", :force => true do |t|
    t.string   "uid"
    t.string   "name"
    t.text     "content"
    t.string   "url"
    t.datetime "posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", :force => true do |t|
    t.integer  "match_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "team_ids"
    t.boolean  "won",          :default => false
    t.string   "opponent_ids"
    t.integer  "account_id"
  end

  add_index "teams", ["account_id"], :name => "index_teams_on_account_id"
  add_index "teams", ["opponent_ids"], :name => "index_teams_on_opponent_ids"
  add_index "teams", ["team_ids"], :name => "index_teams_on_team_ids"

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
    t.integer  "comments_count",                          :default => 0
    t.integer  "account_id"
    t.boolean  "is_account_admin",                        :default => false
    t.boolean  "enabled",                                 :default => true
    t.string   "feed_token"
    t.string   "login_token"
    t.string   "time_zone"
    t.integer  "last_game_id"
    t.string   "cache_game_ids"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"

end
