require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "signing up creates an account and redirects to tasks" do
    post signup_path, params: { user: { name: "New User", email: "new@example.com", password: "password", password_confirmation: "password" } }
    assert_redirected_to tasks_path
    follow_redirect!
    assert_response :success
  end

  test "too many signup attempts returns 429 with alert" do
    5.times do |i|
      post signup_path, params: { user: { name: "User #{i}", email: "user#{i}@example.com", password: "password", password_confirmation: "password" } }
    end
    post signup_path, params: { user: { name: "Blocked", email: "blocked@example.com", password: "password", password_confirmation: "password" } }
    assert_response :too_many_requests
    assert_match "Too many signup attempts", response.body
  end
end
