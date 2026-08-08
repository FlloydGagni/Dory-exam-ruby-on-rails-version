# A shared, global label that tasks can be filed under. Categories are not owned by a
# specific user (no `user_id` column) - every signed-in user sees the same category list.
class Category < ApplicationRecord
  # Deliberately no `dependent:` option here: deleting a category isn't exposed in the UI
  # (see README "Known Limitations"), so this app never needs to decide what happens to
  # the tasks that reference it.
  has_many :tasks

  # Every category must have a name, and names cannot repeat.
  validates :name, presence: true, uniqueness: true
end
