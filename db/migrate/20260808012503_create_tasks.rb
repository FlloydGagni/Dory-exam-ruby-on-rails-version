# Creates the `tasks` table, the app's central resource. Each task belongs to exactly one
# category and one user (both required foreign keys), which is what lets TasksController
# scope every query to `current_user.tasks` for per-user data isolation.
class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      # Stored as the enum's string value (see Task model); defaults every new task to pending.
      t.string :status, null: false, default: "pending"
      t.date :due_date
      # `references` adds a `category_id` bigint column, an index on it, and a foreign key
      # constraint (so a task can never point at a nonexistent category).
      t.references :category, null: false, foreign_key: true
      # Same as above, but for `user_id`.
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
