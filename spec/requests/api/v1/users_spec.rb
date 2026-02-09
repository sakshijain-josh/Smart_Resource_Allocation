require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:employee) { create(:user) }

  describe "GET /api/v1/users" do
    it "allows admin to index users" do
      create(:user) # ensure at least one more
      get api_v1_users_path, headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["users"].size).to be >= 2
      puts "✅ PASS: Admin can list all users (Normal Case)"
    end

    it "blocks employee from indexing users" do
      get api_v1_users_path, headers: auth_headers(employee), as: :json
      expect(response).to have_http_status(:forbidden)
      puts "✅ PASS: Unauthorized index access blocked (Edge Case: RBAC)"
    end
  end

  describe "POST /api/v1/users" do
    it "allows admin to create user" do
      expect {
        post api_v1_users_path,
             params: { employee_id: "EMP999", name: "New Joiner", email: "new@example.com", password: "password", role: "employee" },
             headers: auth_headers(admin),
             as: :json
      }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
      puts "✅ PASS: Admin can create user (Normal Case)"
    end
  end

  describe "DELETE /api/v1/users/:id" do
    it "blocks admin from deleting self" do
      delete api_v1_user_path(admin), headers: auth_headers(admin), as: :json
      expect(response).to have_http_status(:forbidden)
      puts "✅ PASS: Admin self-deletion blocked (Edge Case: Business Logic)"
    end

    it "allows admin to delete employee" do
      emp = create(:user)
      expect {
        delete api_v1_user_path(emp), headers: auth_headers(admin), as: :json
      }.to change(User, :count).by(-1)
      expect(response).to have_http_status(:ok)
      puts "✅ PASS: Admin can delete employee (Normal Case)"
    end
  end
end
