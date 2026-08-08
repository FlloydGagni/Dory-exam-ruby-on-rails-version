# Creates the `categories` table. Deliberately has no `user_id` column: categories are
# shared/global, not owned by an individual user (see Category model and README).
class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false

      t.timestamps
    end

    # Prevents duplicate category names at the database level.
    add_index :categories, :name, unique: true
  end
end
