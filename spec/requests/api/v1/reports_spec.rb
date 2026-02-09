require "rails_helper"

RSpec.describe "Api::V1::Reports", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:employee) { create(:user) }
  let(:resource) { create(:resource) }

  before do
    create(:booking, user: employee, resource: resource, status: :approved)
  end

  describe "GET /api/v1/reports/resource_usage" do
    it "allows admin to access resource usage report" do
      get api_v1_reports_resource_usage_path, headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["report_type"]).to eq("resource_usage")
      expect(json["data"]).to be_present
      puts "✅ PASS: Admin can access resource usage report (Normal Case)"
    end

    it "blocks employee from accessing report" do
      get api_v1_reports_resource_usage_path, headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:forbidden)
      puts "✅ PASS: Unauthorized report access blocked (Edge Case: RBAC)"
    end
  end

  describe "GET /api/v1/reports/user_bookings" do
    it "allows admin to access user bookings report" do
      get api_v1_reports_user_bookings_path, headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["report_type"]).to eq("user_bookings_summary")
      puts "✅ PASS: Admin can access user bookings summary (Normal Case)"
    end
  end

  describe "GET /api/v1/reports/peak_hours" do
    it "allows admin to access peak hours report" do
      get api_v1_reports_peak_hours_path, headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["report_type"]).to eq("peak_hours_analysis")
      puts "✅ PASS: Admin can access peak hours analysis (Normal Case)"
    end
  end

  describe "GET /api/v1/reports/utilization" do
    it "allows admin to access resource utilization report" do
      get api_v1_reports_utilization_path, headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["report_type"]).to eq("resource_utilization")
      expect(json).to have_key("over_utilised")
      expect(json).to have_key("under_utilised")
      expect(json).to have_key("summary")
      puts "✅ PASS: Admin can access resource utilization report (Normal Case)"
    end
  end
end
