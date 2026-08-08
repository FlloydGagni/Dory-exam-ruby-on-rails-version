class Task < ApplicationRecord
  belongs_to :category
  belongs_to :user

  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed" }, default: :pending

  validates :title, presence: true
end
