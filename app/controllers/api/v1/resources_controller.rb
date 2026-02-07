module Api
  module V1
    class ResourcesController < ApplicationController
      # before_action :authenticate_user! is inherited from ApplicationController

      before_action :set_resource, only: [ :show, :availability, :update, :destroy ]

      # GET /api/v1/resources
      def index
        authorize! :read, Resource
        @resources = Resource.all

        # Apply filters if present
        @resources = @resources.where(resource_type: params[:resource_type]) if params[:resource_type].present?
        @resources = @resources.where(location: params[:location]) if params[:location].present?
        @resources = @resources.where(is_active: params[:is_active]) if params[:is_active].present?

        # Pagination
        limit = (params[:limit] || ENV.fetch("DEFAULT_API_LIMIT", 10)).to_i
        offset = (params[:offset] || 0).to_i

        total_count = @resources.count
        paginated_resources = @resources.limit(limit).offset(offset)

        render json: {
          resources: paginated_resources,
          total: total_count,
          limit: limit,
          offset: offset,
          has_more: (offset + limit) < total_count
        }
      end

      # GET /api/v1/resources/:id
      def show
        authorize! :read, @resource
        render json: @resource
      end

      # GET /api/v1/resources/:id/availability
      def availability
        authorize! :availability, @resource

        # Get optional query parameters with robust parsing
        begin
          date = params[:date].present? ? Date.parse(params[:date].to_s) : Date.today
        rescue ArgumentError, Date::Error
          date = Date.today
        end

        duration = params[:duration].to_f
        duration = 1.0 if duration <= 0

        # Calculate available slots
        slots = @resource.available_slots(date, duration)

        # Render availability info
        render json: {
          resource_id: @resource.id,
          resource_name: @resource.name,
          query_date: date.to_s,
          slot_duration_hours: duration,
          available_slots: slots
        }
      end

      # POST /api/v1/resources
      def create
        @resource = Resource.new(resource_params)
        authorize! :create, @resource
        if @resource.save
          render json: @resource, status: :created
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/resources/:id
      def update
        authorize! :update, @resource
        if @resource.update(resource_params)
          render json: @resource
        else
          render json: { errors: @resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/resources/:id
      def destroy
        authorize! :destroy, @resource
        @resource.destroy
        head :no_content
      end

      private

      def set_resource
        @resource = Resource.find(params[:id])
      end

      # Strong params to protect against mass assignment
      def resource_params
        params.permit(:name, :resource_type, :description, :location, :is_active, properties: {})
      end
    end
  end
end
