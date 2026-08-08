# A single to-do item owned by a user and filed under a category.
class Task < ApplicationRecord
  # Every task must reference an existing category (the `category_id` foreign key is required).
  belongs_to :category
  # Every task must reference the user who owns it (the `user_id` foreign key is required).
  belongs_to :user

  # Restricts `status` to these three values, stored as the strings themselves in the database.
  # This also generates helper methods like `task.pending?`, `task.completed!`, and the
  # `Task.statuses` map used to build the status dropdown in the UI.
  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed" }, default: :pending

  # Every task must have a title.
  validates :title, presence: true
end
