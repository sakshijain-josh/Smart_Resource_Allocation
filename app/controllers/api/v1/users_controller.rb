module Api
  module V1
    class UsersController < ApplicationController
      # before_action :authenticate_user! is already in ApplicationController
      
      def create
        authorize! :create, User
        
        user = User.new(user_params)
        
        if user.save
          render json: {
            message: 'User created successfully',
            user: {
              id: user.id,
              employee_id: user.employee_id,
              name: user.name,
              email: user.email,
              role: user.role
            }
          }, status: :created
        else
          render json: {
            error: 'Validation failed',
            messages: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:employee_id, :name, :email, :password, :role)
      end
    end
  end
end
