# Creates the `users` table backing the User model (account holders who sign in and own tasks).
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      # Holds the bcrypt hash produced by `has_secure_password`, never the raw password.
      t.string :password_digest, null: false

      # Adds created_at/updated_at columns, managed automatically by Active Record.
      t.timestamps
    end

    # Enforces one account per email address at the database level (in addition to the
    # model-level uniqueness validation).
    add_index :users, :email, unique: true
  end
end
