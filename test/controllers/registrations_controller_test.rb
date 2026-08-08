require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "signing up creates an account and redirects to tasks" do
    post signup_path, params: { user: { name: "New User", email: "new@example.com", password: "password", password_confirmation: "password" } }
    assert_redirected_to tasks_path
    follow_redirect!
    assert_response :success
  end
end
