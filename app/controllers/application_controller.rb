class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :require_authentication!

  def current_user
    return @current_user if @current_user
    
    # Use the correct scope based on Devise mapping (:api_v1_user)
    @current_user = warden.authenticate(:jwt, scope: :api_v1_user)
  end

  def require_authentication!
    render json: { error: 'Unauthorized', message: 'You need to sign in to access this resource' }, status: :unauthorized unless current_user
  end

  private

  def warden
    request.env['warden']
  end

  # CanCanCan error handling
  rescue_from CanCan::AccessDenied do |exception|
    render json: {
      error: 'Access denied',
      message: exception.message
    }, status: :forbidden
  end

  # Handle records not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {
      error: 'Record not found',
      message: exception.message
    }, status: :not_found
  end
end

