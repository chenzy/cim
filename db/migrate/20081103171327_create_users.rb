class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :name,       :limit => 32
      t.string   :title,            :limit => 64 
      t.string   :alt_email,        :limit => 64
      t.string   :phone,            :limit => 32
      t.string   :mobile,           :limit => 32
      t.boolean  :admin,  :null => false, :default => false
      t.datetime  :suspended_at
      # >>> The following fields are required and maintained by [authlogic] plugin.
      t.string :login, :null => false
      t.string :email, :null => false, :default => "", :limit => 64
      t.string :crypted_password, :null => false
      t.string :password_salt, :null => false
      t.string :persistence_token, :null => false
      t.integer :login_count, :default => 0, :null => false
      t.string   :perishable_token, :null => false, :default => ""
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string :last_login_ip
      t.string :current_login_ip
      # >>> End of [authlogic] maintained fields.
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :users, :login
    add_index :users, :persistence_token
    add_index :users, :last_request_at
    add_index :users, :perishable_token
    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end
