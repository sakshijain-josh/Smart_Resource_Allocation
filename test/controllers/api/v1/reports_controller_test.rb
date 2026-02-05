require "test_helper"

class Api::V1::ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @employee = create(:user)
    @resource = create(:resource)
    create(:booking, user: @employee, resource: @resource, status: :approved)
  end

  test "admin can access resource usage report" do
    get api_v1_reports_resource_usage_url, headers: auth_headers(@admin), as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "resource_usage", json["report_type"]
    assert json["data"].present?
    puts "✅ PASS: Admin can access resource usage report"
  end

  test "admin can access user bookings report" do
    get api_v1_reports_user_bookings_url, headers: auth_headers(@admin), as: :json
    assert_response :success
    assert_equal "user_bookings_summary", JSON.parse(response.body)["report_type"]
    puts "✅ PASS: Admin can access user bookings report"
  end

  test "admin can access peak hours report" do
    get api_v1_reports_peak_hours_url, headers: auth_headers(@admin), as: :json
    assert_response :success
    assert_equal "peak_hours_analysis", JSON.parse(response.body)["report_type"]
    puts "✅ PASS: Admin can access peak hours report"
  end

  test "employee cannot access reports" do
    get api_v1_reports_resource_usage_url, headers: auth_headers(@employee), as: :json
    assert_response :forbidden
    puts "✅ PASS: Unauthorized report access blocked (Data Privacy)"
  end
end
