require "test_helper"

class Api::V1::BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @employee = create(:user)
    @resource = create(:resource, resource_type: "meeting-room")
    @booking = create(:booking, user: @employee, resource: @resource)
  end

  test "should get index as admin" do
    get api_v1_bookings_url, headers: auth_headers(@admin), as: :json
    assert_response :success
    assert_equal 1, JSON.parse(response.body)["bookings"].size
    puts "✅ PASS: Admin can list all bookings"
  end

  test "should get index as employee (seeing only own bookings)" do
    other_employee = create(:user)
    create(:booking, user: other_employee, resource: @resource)

    get api_v1_bookings_url, headers: auth_headers(@employee), as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json["bookings"].size
    assert_equal @employee.id, json["bookings"].first["user_id"]
    puts "✅ PASS: Employees only see their own bookings (Authorization Enforcement)"
  end

  test "should create booking" do
    # 10 AM on a Wednesday in 2027
    date = Date.new(2027, 1, 6)
    start_time = Time.utc(date.year, date.month, date.day, 10, 0, 0)
    end_time = Time.utc(date.year, date.month, date.day, 11, 0, 0)

    assert_difference("Booking.count") do
      post api_v1_bookings_url,
           params: { resource_id: @resource.id, start_time: start_time, end_time: end_time },
           headers: auth_headers(@employee),
           as: :json
    end
    assert_response :created
    puts "✅ PASS: Authorized user can create a booking"
  end

  test "should return suggestions on overlap" do
    date = Date.new(2027, 1, 6)
    start1 = Time.utc(date.year, date.month, date.day, 10, 0, 0)
    end1 = Time.utc(date.year, date.month, date.day, 11, 0, 0)
    create(:booking, resource: @resource, start_time: start1, end_time: end1, status: :approved)

    post api_v1_bookings_url,
         params: { resource_id: @resource.id, start_time: start1, end_time: end1 },
         headers: auth_headers(@employee),
         as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["suggestions"].present?
    puts "✅ PASS: Suggestions provided on conflict (User Experience/Edge Case)"
  end

  test "should check in to approved booking" do
    @booking.update!(status: :approved)
    post check_in_api_v1_booking_url(@booking), headers: auth_headers(@employee), as: :json
    assert_response :success
    assert @booking.reload.checked_in_at.present?
    puts "✅ PASS: User can check-in to approved booking"
  end

  test "should not check in to unapproved booking" do
    post check_in_api_v1_booking_url(@booking), headers: auth_headers(@employee), as: :json
    assert_response :forbidden
    puts "✅ PASS: Cannot check-in to pending booking (Workflow Enforcement)"
  end

  test "should release expired bookings (Admin only)" do
    post release_expired_api_v1_bookings_url, headers: auth_headers(@admin), as: :json
    assert_response :success
    puts "✅ PASS: Admin can trigger auto-release job manually"
  end

  test "employee cannot release expired bookings" do
    post release_expired_api_v1_bookings_url, headers: auth_headers(@employee), as: :json
    assert_response :forbidden
    puts "✅ PASS: Unauthorized release attempts blocked (Security)"
  end
end
