module Api
  module V1
    class UsersController < ApplicationController
      # before_action :authenticate_user! is already in ApplicationController
      
      def index
        authorize! :manage, User
        
        # Pagination parameters
        limit = (params[:limit] || 10).to_i
        offset = (params[:offset] || 0).to_i
        
        # Get paginated users
        total_count = User.count
        users = User.limit(limit).offset(offset)
        
        render json: {
          users: users,
          total: total_count,
          limit: limit,
          offset: offset,
          has_more: (offset + limit) < total_count
        }, status: :ok
      end
      
      def create
        authorize! :create, User
        
        user = User.new(user_params)
        
        if user.save
          render json: {
            message: 'User created successfully',
            user: user
          }, status: :created
        else
          render json: {
            error: 'Validation failed',
            messages: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize! :destroy, User
        
        user = User.find(params[:id])
        
        # Prevent admin from deleting themselves
        if user.id == current_user.id
          render json: {
            error: 'Cannot delete your own account'
          }, status: :forbidden
          return
        end
        
        if user.destroy
          render json: {
            message: 'User deleted successfully'
          }, status: :ok
        else
          render json: {
            error: 'Failed to delete user',
            messages: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:employee_id, :name, :email, :password, :role)
      end
    end
  end
end
