class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      ## Database authenticatable
      t.change :login, :string, :limit => nil
      #t.string :email, :null => false, :default => ""
      #t.string :encrypted_password, :null => false, :default => ""
      t.rename :crypted_password, :encrypted_password
      t.change :encrypted_password, :string, :limit => nil

      ## Recoverable
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      t.string :authentication_token


      # Uncomment below if timestamps were not included in your original model.
      t.timestamps


      # Remove old columns
      t.remove :token
      t.remove :auth_type
      t.remove :open_id_url
    end

    #add_index :users, :email,                :unique => true
    #add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

  def self.down
    change_table(:users) do |t|
      ## Database authenticatable
      t.change :login, :string, :limit => 80
      #t.string :email, :null => false, :default => ""
      #t.string :encrypted_password, :null => false, :default => ""
      t.change :encrypted_password, :string, :limit => 40
      t.rename :encrypted_password, :crypted_password

      ## Recoverable
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      ## Rememberable
      t.remove :remember_created_at

      ## Trackable
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      t.remove :authentication_token


      # Uncomment below if timestamps were not included in your original model.
      t.remove :created_at
      t.remove :updated_at


      # Remove old columns
      t.string :token
      t.string :auth_type, :default => 'database', :null => false
      t.string :open_id_url
    end

    #add_index :users, :email,                :unique => true
    #add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end
end
