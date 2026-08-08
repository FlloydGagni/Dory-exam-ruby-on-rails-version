require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "invalid login shows error and stays on login page" do
    post login_path, params: { email: "nope@example.com", password: "wrong" }
    assert_response :unprocessable_entity
    assert_match "Invalid email or password", response.body
  end

  test "unauthenticated access to tasks redirects to login with alert" do
    get tasks_path
    assert_redirected_to login_path
    follow_redirect!
    assert_match "You must be logged in", response.body
  end

  test "valid login redirects to tasks" do
    User.create!(name: "Test", email: "test@example.com", password: "password", password_confirmation: "password")
    post login_path, params: { email: "test@example.com", password: "password" }
    assert_redirected_to tasks_path
    follow_redirect!
    assert_response :success
  end

  test "login succeeds when email casing differs from what was stored (e.g. browser autocapitalized it)" do
    User.create!(name: "Test", email: "test@example.com", password: "password", password_confirmation: "password")
    post login_path, params: { email: "Test@Example.com", password: "password" }
    assert_redirected_to tasks_path
  end

  test "login succeeds when email has leading/trailing whitespace" do
    User.create!(name: "Test", email: "test@example.com", password: "password", password_confirmation: "password")
    post login_path, params: { email: " test@example.com ", password: "password" }
    assert_redirected_to tasks_path
  end

  test "too many login attempts returns 429 with alert" do
    10.times { post login_path, params: { email: "nope@example.com", password: "wrong" } }
    post login_path, params: { email: "nope@example.com", password: "wrong" }
    assert_response :too_many_requests
    assert_match "Too many login attempts", response.body
  end
end
