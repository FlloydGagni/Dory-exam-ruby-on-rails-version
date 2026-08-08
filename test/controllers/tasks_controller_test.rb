require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "too many requests to a normal endpoint returns 429" do
    user = User.create!(name: "Test", email: "limit@example.com", password: "password", password_confirmation: "password")
    post login_path, params: { email: user.email, password: "password" }

    101.times { get tasks_path }

    assert_response :too_many_requests
  end
end
