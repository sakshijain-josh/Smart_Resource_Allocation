module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token, raise: false
      skip_before_action :require_authentication!, only: [ :create ], raise: false
      skip_before_action :verify_signed_out_user, only: [ :destroy ], raise: false

      respond_to :json

      # Override create to handle API authentication
      def create
        email = params[:email]
        password = params[:password]

        user = User.find_by(email: email)

        if user && user.valid_password?(password)
          # Use warden to set the user without sessions
          warden.set_user(user, store: false)

          render json: {
            token: request.env["warden-jwt_auth.token"],
            user: user,
            expires_at: 24.hours.from_now
          }, status: :ok
        else
          render json: {
            error: "Invalid email or password"
          }, status: :unauthorized
        end
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            token: request.env["warden-jwt_auth.token"],
            user: resource,
            expires_at: 24.hours.from_now
          }, status: :ok
        else
          render json: {
            error: "Invalid credentials"
          }, status: :unauthorized
        end
      end

      def respond_to_on_destroy(*)
        if request.headers["Authorization"].present?
          begin
            jwt_payload = JWT.decode(
              request.headers["Authorization"].split(" ").last,
              Rails.application.credentials.devise_jwt_secret_key || Rails.application.secret_key_base
            ).first
            current_user = User.find(jwt_payload["sub"])
          rescue JWT::DecodeError, ActiveRecord::RecordNotFound
            current_user = nil
          end
        end

        if current_user
          render json: {
            message: "Logged out successfully"
          }, status: :ok
        else
          render json: {
            error: "No active session"
          }, status: :unauthorized
        end
      end
    end
  end
end
