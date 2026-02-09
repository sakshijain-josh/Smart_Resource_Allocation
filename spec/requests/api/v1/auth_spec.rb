require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  let(:user) { create(:user) }

  describe "GET /api/v1/auth/me" do
    it "returns the current user" do
      get api_v1_auth_me_path, headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["email"]).to eq(user.email)
      puts "✅ PASS: Registration show (me) endpoint functional (Normal Case)"
    end
  end

  describe "POST /api/v1/users/sign_in" do
    it "logs in successfully" do
      post api_v1_user_session_path,
           params: { email: user.email, password: "password123" },
           as: :json
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["token"]).to be_present
      puts "✅ PASS: Auth Login endpoint functional (Normal Case)"
    end

    it "fails with wrong password" do
      post api_v1_user_session_path,
           params: { email: user.email, password: "wrongpassword" },
           as: :json
      expect(response).to have_http_status(:unauthorized)
      puts "✅ PASS: Auth Login fails with wrong credentials (Edge Case: Incorrect Password)"
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    it "logs out successfully" do
      delete destroy_api_v1_user_session_path, headers: auth_headers(user), as: :json
      expect(response).to have_http_status(:success)
      puts "✅ PASS: Auth Logout endpoint functional (Normal Case)"
    end
  end
end
