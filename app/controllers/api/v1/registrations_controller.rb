module Api
  module V1
    class RegistrationsController < ApplicationController
      respond_to :json
      before_action :require_authentication!

      # why do we have show method here
      def show
        render json: current_user, status: :ok
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            user: resource
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
