# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Shared categories available to every user.
categories = ["Work", "Personal", "Shopping", "Health"].map do |name|
  Category.find_or_create_by!(name: name)
end

# Test accounts for local development and reviewer sign-in.
# Password is the same for both so they're easy to remember while testing.
test_accounts = [
  { name: "Test User", email: "test@example.com", password: "password123" },
  { name: "Jane Reviewer", email: "reviewer@example.com", password: "password123" }
]

test_accounts.each do |attrs|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.password = attrs[:password]
    u.password_confirmation = attrs[:password]
  end

  # Give the primary test user a handful of sample tasks so the task list isn't empty on first login.
  next unless attrs[:email] == "test@example.com"
  next if user.tasks.exists?

  user.tasks.create!(title: "Buy groceries", description: "Milk, eggs, bread", status: :pending, category: categories.find { |c| c.name == "Shopping" }, due_date: Date.current + 2)
  user.tasks.create!(title: "Finish quarterly report", description: "Due before the Friday meeting", status: :in_progress, category: categories.find { |c| c.name == "Work" }, due_date: Date.current + 5)
  user.tasks.create!(title: "Morning run", description: "5k around the park", status: :completed, category: categories.find { |c| c.name == "Health" })
end

puts "Seeded #{Category.count} categories and #{User.count} users."
