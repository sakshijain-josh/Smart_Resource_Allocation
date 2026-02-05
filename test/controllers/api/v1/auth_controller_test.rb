require "test_helper"

class Api::V1::AuthTests < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @admin = create(:user, :admin)
  end

  test "should get current user via registrations show" do
    get api_v1_auth_me_url, headers: auth_headers(@user), as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @user.email, json["email"]
    puts "✅ PASS: Auth Registration show (me) endpoint functional"
  end

  test "should login successfully" do
    post api_v1_user_session_url, 
         params: { email: @user.email, password: 'password123' }, 
         as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert json["token"].present?
    puts "✅ PASS: Auth Login endpoint functional"
  end

  test "should fail login with wrong password" do
    post api_v1_user_session_url, 
         params: { email: @user.email, password: 'wrongpassword' }, 
         as: :json
    assert_response :unauthorized
    puts "✅ PASS: Auth Login fails with wrong credentials"
  end

  test "should logout successfully" do
    delete destroy_api_v1_user_session_url, headers: auth_headers(@user), as: :json
    assert_response :success
    puts "✅ PASS: Auth Logout endpoint functional"
  end

  test "should provide suggestions on booking conflict" do
    # Create two resources of same type
    resource1 = create(:resource, resource_type: 'meeting-room')
    resource2 = create(:resource, resource_type: 'meeting-room')
    
    start_time = Time.utc(2027, 2, 1, 10, 0, 0)
    end_time = Time.utc(2027, 2, 1, 11, 0, 0)
    create(:booking, :approved, resource: resource1, start_time: start_time, end_time: end_time)
    
    # Try to create an overlapping booking on resource1
    post api_v1_bookings_url,
         params: { resource_id: resource1.id, start_time: start_time, end_time: end_time },
         headers: auth_headers(@user),
         as: :json
         
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["suggestions"].present?
    assert_kind_of Array, json["suggestions"]["available_resources"]
    assert_kind_of Array, json["suggestions"]["available_slots"]
    # At least one resource (resource2) should be suggested
    assert json["suggestions"]["available_resources"].any? { |r| r["id"] == resource2.id }
    puts "✅ PASS: Booking suggestions provided on conflict"
  end
end
