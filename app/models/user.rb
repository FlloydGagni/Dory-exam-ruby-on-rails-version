# Represents an account holder who can sign in and own tasks.
class User < ApplicationRecord
  # Adds `password`/`password_confirmation` virtual attributes, a `password_digest`-backed
  # `authenticate` method, and validations (via bcrypt, since the `password_digest` column exists).
  has_secure_password

  # A user's tasks are deleted along with the user (no orphaned tasks left behind).
  has_many :tasks, dependent: :destroy

  # Trims whitespace and lowercases email before it is validated/saved, so "A@Example.com "
  # and "a@example.com" are treated as the same address.
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Every user must have a name.
  validates :name, presence: true
  # Every user must have an email, and no two users can share one.
  validates :email, presence: true, uniqueness: true
end
