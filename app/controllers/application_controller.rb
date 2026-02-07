class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :require_authentication!

  def current_user
    return @current_user if @current_user

    w = warden
    return nil unless w

    # Use the correct scope based on Devise mapping (:api_v1_user)
    @current_user = w.authenticate(:jwt, scope: :api_v1_user) || w.user(scope: :api_v1_user)
  end

  def require_authentication!
    render json: {
      error: "Unauthorized",
      message: "You need to sign in to access this resource"
    },
    status: :unauthorized unless current_user
  end

  protected

  def enforce_flat_params!
    # Check if the root key of the controller exists (e.g., params[:resource] or params[:booking])
    resource_key = controller_name.singularize
    if params.has_key?(resource_key) && params[resource_key].is_a?(Hash)
      render json: {
        error: "Bad Request",
        message: "Nested parameters are not allowed. Please provide attributes in a flat structure. Found nested key: '#{resource_key}'"
      }, status: :bad_request
    end
  end

  private

  def warden
    begin
      request.env["warden"] if request && request.respond_to?(:env) && request.env
    rescue => e
      puts "WARDEN ERROR: #{e.message}"
      puts e.backtrace.first(5)
      nil
    end
  end

  # CanCanCan error handling
  rescue_from CanCan::AccessDenied do |exception|
    render json: {
      error: "Access denied",
      message: exception.message
    }, status: :forbidden
  end

  # Handle records not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {
      error: "Record not found",
      message: exception.message
    }, status: :not_found
  end
end
