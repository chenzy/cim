# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091016134230) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "action",       :limit => 32, :default => "created"
    t.string   "info",                       :default => ""
    t.boolean  "private",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "c_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",       :limit => 32, :default => "", :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["user_id", "name"], :name => "index_preferences_on_user_id_and_name"

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "spec"
    t.string   "unit"
    t.decimal  "unit_price", :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "name",          :limit => 32, :default => "", :null => false
    t.text     "value"
    t.text     "default_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name"

  create_table "users", :force => true do |t|
    t.string   "name",              :limit => 32
    t.string   "title",             :limit => 64
    t.string   "alt_email",         :limit => 64
    t.string   "phone",             :limit => 32
    t.string   "mobile",            :limit => 32
    t.boolean  "admin",                           :default => false, :null => false
    t.datetime "suspended_at"
    t.string   "login",                                              :null => false
    t.string   "email",             :limit => 64, :default => "",    :null => false
    t.string   "crypted_password",                                   :null => false
    t.string   "password_salt",                                      :null => false
    t.string   "persistence_token",                                  :null => false
    t.integer  "login_count",                     :default => 0,     :null => false
    t.string   "perishable_token",                :default => "",    :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  create_table "warehouse_list_items", :force => true do |t|
    t.integer  "warehouse_list_id"
    t.integer  "product_id"
    t.decimal  "amount",            :precision => 18, :scale => 2, :null => false
    t.decimal  "unit_price",        :precision => 18, :scale => 2, :null => false
    t.decimal  "total",             :precision => 18, :scale => 2, :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "warehouse_lists", :force => true do |t|
    t.string   "w_type"
    t.integer  "customer_id"
    t.string   "number"
    t.datetime "happen_time"
    t.decimal  "total",       :precision => 18, :scale => 2, :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "waste_books", :force => true do |t|
    t.integer  "customer_id"
    t.datetime "happen_time"
    t.string   "w_type"
    t.decimal  "money",       :precision => 18, :scale => 2, :null => false
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
