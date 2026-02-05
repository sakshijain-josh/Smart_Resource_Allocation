require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @employee = create(:user)
  end

  test "admin can index users" do
    get api_v1_users_url, headers: auth_headers(@admin), as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 2, json["users"].size
    puts "✅ PASS: Admin can list all users"
  end

  test "employee cannot index users" do
    get api_v1_users_url, headers: auth_headers(@employee), as: :json
    assert_response :forbidden
    puts "✅ PASS: Employee blocked from listing users"
  end

  test "admin can create user" do
    assert_difference 'User.count', 1 do
      post api_v1_users_url,
           params: { employee_id: 'EMP999', name: 'New Joiner', email: 'new@example.com', password: 'password', role: 'employee' },
           headers: auth_headers(@admin),
           as: :json
    end
    assert_response :created
    puts "✅ PASS: Admin can create new users"
  end

  test "admin cannot delete self" do
    delete api_v1_user_url(@admin), headers: auth_headers(@admin), as: :json
    assert_response :forbidden
    puts "✅ PASS: Admin cannot delete their own account (Self-Preservation)"
  end

  test "admin can delete employee" do
    assert_difference 'User.count', -1 do
      delete api_v1_user_url(@employee), headers: auth_headers(@admin), as: :json
    end
    assert_response :ok
    puts "✅ PASS: Admin can delete employee accounts"
  end
end
