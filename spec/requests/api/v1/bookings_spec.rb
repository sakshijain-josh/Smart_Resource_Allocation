require "rails_helper"

RSpec.describe "Api::V1::Bookings", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:employee) { create(:user) }
  let(:resource) { create(:resource, resource_type: "meeting-room") }
  let!(:booking) { create(:booking, user: employee, resource: resource) }

  describe "GET /api/v1/bookings" do
    it "allows admin to list all bookings" do
      get api_v1_bookings_path, headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["bookings"].size).to eq(1)
      puts "✅ PASS: Admin can list all bookings (Normal Case)"
    end

    it "allows employee to see only their own bookings" do
      other_employee = create(:user)
      create(:booking, user: other_employee, resource: resource)

      get api_v1_bookings_path, headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["bookings"].size).to eq(1)
      expect(json["bookings"].first["user_id"]).to eq(employee.id)
      puts "✅ PASS: Employees only see their own bookings (Normal Case: Context Filtering)"
    end
  end

  describe "POST /api/v1/bookings" do
    let(:date) { Date.new(2027, 1, 6) }
    let(:start_time) { Time.utc(date.year, date.month, date.day, 10, 0, 0) }
    let(:end_time) { Time.utc(date.year, date.month, date.day, 11, 0, 0) }

    it "creates a booking for authorized user" do
      expect {
        post api_v1_bookings_path,
             params: { resource_id: resource.id, start_time: start_time, end_time: end_time },
             headers: auth_headers(employee),
             as: :json
      }.to change(Booking, :count).by(1)
      expect(response).to have_http_status(:created)
      puts "✅ PASS: Authorized user can create a booking (Normal Case)"
    end

    it "returns suggestions on overlap" do
      create(:booking, resource: resource, start_time: start_time, end_time: end_time, status: :approved)

      post api_v1_bookings_path,
           params: { resource_id: resource.id, start_time: start_time, end_time: end_time },
           headers: auth_headers(employee),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["suggestions"]).to be_present
      puts "✅ PASS: Suggestions provided on conflict (Edge Case: Collision Detection)"
    end

    it "provides suggestions on booking conflict with multiple resources" do
      # Create two resources of same type
      resource1 = create(:resource, resource_type: "meeting-room")
      resource2 = create(:resource, resource_type: "meeting-room")

      start_time_conflict = Time.utc(2027, 2, 1, 10, 0, 0)
      end_time_conflict = Time.utc(2027, 2, 1, 11, 0, 0)
      create(:booking, :approved, resource: resource1, start_time: start_time_conflict, end_time: end_time_conflict)

      # Try to create an overlapping booking on resource1
      post api_v1_bookings_path,
           params: { resource_id: resource1.id, start_time: start_time_conflict, end_time: end_time_conflict },
           headers: auth_headers(employee),
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["suggestions"]).to be_present
      expect(json["suggestions"]["available_resources"]).to be_an(Array)
      expect(json["suggestions"]["available_slots"]).to be_an(Array)
      # At least one resource (resource2) should be suggested
      expect(json["suggestions"]["available_resources"].any? { |r| r["id"] == resource2.id }).to be true
      puts "✅ PASS: Booking suggestions provided with alternative resources (Edge Case: Multi-Resource Collision)"
    end
  end

  describe "POST /api/v1/bookings/:id/check_in" do
    it "allows check-in to approved booking" do
      booking.update!(status: :approved)
      post check_in_api_v1_booking_path(booking), headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:success)
      expect(booking.reload.checked_in_at).to be_present
      puts "✅ PASS: User can check-in to approved booking (Normal Case: Lifecycle)"
    end

    it "blocks check-in to unapproved booking" do
      post check_in_api_v1_booking_path(booking), headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:forbidden)
      puts "✅ PASS: Cannot check-in to pending booking (Edge Case: Invalid Lifecycle State)"
    end
  end

  describe "POST /api/v1/bookings/release_expired" do
    it "allows admin to trigger auto-release job" do
      post release_expired_api_v1_bookings_path, headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:success)
      puts "✅ PASS: Admin can trigger auto-release job (Normal Case: Admin Tooling)"
    end

    it "blocks employee from triggered auto-release job" do
      post release_expired_api_v1_bookings_path, headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:forbidden)
      puts "✅ PASS: Unauthorized release attempts blocked (Edge Case: Security/RBAC)"
    end
  end
end
