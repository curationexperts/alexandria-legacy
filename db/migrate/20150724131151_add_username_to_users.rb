class AddUsernameToUsers < ActiveRecord::Migration
  def change
    rename_column :users, :email, :username
    rename_index :users, 'index_users_on_email', 'index_users_on_username'
    remove_columns :users, :reset_password_token, :reset_password_sent_at
  end
end
