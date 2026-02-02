module Api
  module V1
    class RegistrationsController < ApplicationController
      respond_to :json
      before_action :authenticate_user!

      def show
        render json: {
          id: current_user.id,
          employee_id: current_user.employee_id,
          name: current_user.name,
          email: current_user.email,
          role: current_user.role
        }, status: :ok
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            user: {
              id: resource.id,
              employee_id: resource.employee_id,
              name: resource.name,
              email: resource.email,
              role: resource.role
            }
          }, status: :created
        else
          render json: {
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
