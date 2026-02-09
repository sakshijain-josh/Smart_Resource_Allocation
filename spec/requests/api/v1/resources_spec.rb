require "rails_helper"

RSpec.describe "Api::V1::Resources", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:employee) { create(:user) }
  let!(:resource) { create(:resource, name: "Meeting Room X", resource_type: "meeting-room") }

  describe "GET /api/v1/resources" do
    it "returns success" do
      get api_v1_resources_path, headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["resources"]).to be_an(Array)
      puts "✅ PASS: Resource listing functional (Normal Case)"
    end
  end

  describe "GET /api/v1/resources/:id" do
    it "returns resource details" do
      get api_v1_resource_path(resource), headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq(resource.name)
      puts "✅ PASS: Resource detail access functional (Normal Case)"
    end
  end

  describe "GET /api/v1/resources/:id/availability" do
    it "returns availability slots" do
      get availability_api_v1_resource_path(resource), headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["available_slots"]).to be_present
      puts "✅ PASS: Resource availability check functional (Normal Case)"
    end
  end

  describe "POST /api/v1/resources" do
    it "allows admin to create resource" do
      expect {
        post api_v1_resources_path,
             params: { name: "New Lab", resource_type: "meeting-room", location: "Block C" },
             headers: auth_headers(admin),
             as: :json
      }.to change(Resource, :count).by(1)
      expect(response).to have_http_status(:created)
      puts "✅ PASS: Admin can create resource (Normal Case)"
    end

    it "blocks employee from creating resource" do
      post api_v1_resources_path,
           params: { name: "Hackers Den", resource_type: "meeting-room" },
           headers: auth_headers(employee),
           as: :json
      expect(response).to have_http_status(:forbidden)
      puts "✅ PASS: Employee resource creation blocked (Edge Case: RBAC)"
    end
  end

  describe "PATCH /api/v1/resources/:id" do
    it "allows admin to update resource" do
      patch api_v1_resource_path(resource), params: { name: "Updated Room X" }, headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:success)
      expect(resource.reload.name).to eq("Updated Room X")
      puts "✅ PASS: Admin can update resource (Normal Case)"
    end
  end

  describe "DELETE /api/v1/resources/:id" do
    it "allows admin to delete resource" do
      expect {
        delete api_v1_resource_path(resource), headers: auth_headers(admin), as: :json
      }.to change(Resource, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      puts "✅ PASS: Admin can delete resource (Normal Case)"
    end
  end
end
