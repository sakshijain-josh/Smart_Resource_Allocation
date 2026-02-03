module Api
  module V1
    class ResourcesController < ApplicationController
      # before_action :authenticate_user! is inherited from ApplicationController
      
      # load_and_authorize_resource is a CanCanCan helper that automatically
      # loads the resource and checks permissions based on Ability class
      load_and_authorize_resource

      # GET /api/v1/resources
      def index
        # @resources is automatically loaded by load_and_authorize_resource
        render json: @resources
      end

      # GET /api/v1/resources/:id
      def show
        # @resource is automatically loaded by load_and_authorize_resource
        render json: @resource
      end

      # POST /api/v1/resources
      def create
        # @resource is initialized with params by load_and_authorize_resource
        if @resource.save
          render json: @resource, status: :created
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/resources/:id
      def update
        # @resource is loaded by load_and_authorize_resource
        if @resource.update(resource_params)
          render json: @resource
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/resources/:id
      def destroy
        # @resource is loaded by load_and_authorize_resource
        @resource.destroy
        head :no_content
      end

      private

      # Strong params to protect against mass assignment
      def resource_params
        params.permit(:name, :resource_type, :description, :location, :is_active, properties: {})
      end
    end
  end
end
