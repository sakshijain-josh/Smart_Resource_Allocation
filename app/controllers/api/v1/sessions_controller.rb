module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token, raise: false
      skip_before_action :authenticate_user!, only: [:create, :destroy]
      skip_before_action :verify_signed_out_user, only: [:destroy], raise: false
      
      respond_to :json

      # Override create to handle API authentication
      def create
        # Handle both nested (params[:user]) and non-nested formats
        email = params[:user]&.[](:email) || params[:email]
        password = params[:user]&.[](:password) || params[:password]
        
        user = User.find_by(email: email)
        
        if user && user.valid_password?(password)
          # Use warden to set the user without sessions
          warden.set_user(user, store: false)
          
          render json: {
            token: request.env['warden-jwt_auth.token'],
            user: {
              id: user.id,
              employee_id: user.employee_id,
              name: user.name,
              email: user.email,
              role: user.role
            },
            expires_at: 24.hours.from_now
          }, status: :ok
        else
          render json: {
            error: 'Invalid email or password'
          }, status: :unauthorized
        end
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            token: request.env['warden-jwt_auth.token'],
            user: {
              id: resource.id,
              employee_id: resource.employee_id,
              name: resource.name,
              email: resource.email,
              role: resource.role
            },
            expires_at: 24.hours.from_now
          }, status: :ok
        else
          render json: {
            error: 'Invalid credentials'
          }, status: :unauthorized
        end
      end

      def respond_to_on_destroy
        if request.headers['Authorization'].present?
          begin
            jwt_payload = JWT.decode(
              request.headers['Authorization'].split(' ').last,
              Rails.application.credentials.devise_jwt_secret_key || Rails.application.secret_key_base
            ).first
            current_user = User.find(jwt_payload['sub'])
          rescue JWT::DecodeError, ActiveRecord::RecordNotFound
            current_user = nil
          end
        end

        if current_user
          render json: {
            message: 'Logged out successfully'
          }, status: :ok
        else
          render json: {
            error: 'No active session'
          }, status: :unauthorized
        end
      end
    end
  end
end
