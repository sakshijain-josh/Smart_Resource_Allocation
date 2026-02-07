module Api
  module V1
    class BookingsController < ApplicationController
      load_and_authorize_resource param_method: :booking_params

      # So in index, before your method body runs, CanCanCan already executes logic similar to:
      # @bookings = Booking.accessible_by(current_ability)

      # GET /api/v1/bookings
      def index
        # @bookings is automatically loaded by load_and_authorize_resource


        # That route maps to: Api::V1::BookingsController#index
        # The filtering happens inside the index method after routing is already resolved.

        # Filtering: Employees only see their own bookings
        @bookings = @bookings.where(user_id: current_user.id) unless current_user.admin?

        # Apply filters if present
        @bookings = @bookings.where(status: params[:status]) if params[:status].present?
        @bookings = @bookings.where(resource_id: params[:resource_id]) if params[:resource_id].present?

        # Pagination
        limit = (params[:limit] || ENV.fetch("DEFAULT_API_LIMIT", 10)).to_i
        offset = (params[:offset] || 0).to_i

        # Preload associations to prevent N+1 and ensure data availability -> eager loading
        # When you fetch bookings fetch user and resource in advance
        @bookings = @bookings.includes(:user, :resource)

        total_count = @bookings.count
        paginated_bookings = @bookings.order(created_at: :desc).limit(limit).offset(offset)

        render json: {
          bookings: paginated_bookings,
          total: total_count,
          limit: limit,
          offset: offset,
          has_more: (offset + limit) < total_count
        }, status: :ok
      end

      # GET /api/v1/bookings/:id
      def show
        render json: @booking
      end

      # POST /api/v1/bookings
      def create
        # Use current_user if user_id is not provided or if user is not admin
        @booking.user_id = current_user.id unless current_user.admin? && params[:user_id].present?
        @booking.performer_id = current_user.id

        if @booking.save
          render json: @booking, status: :created
        else
          response = { errors: @booking.errors.full_messages }

          # Add suggestions if there's an overlap conflict
          if @booking.errors.added?(:base, "This resource is already booked (Approved) for the selected time slot")
            response[:suggestions] = {
              available_resources: @booking.suggest_alternative_resources.as_json(only: [ :id, :name, :resource_type, :location ]),
              available_slots: @booking.suggest_alternative_slots
            }
          end

          render json: response, status: :unprocessable_entity
        end
      end

      # POST /api/v1/bookings/:id/check_in
      def check_in
        @booking.performer_id = current_user.id
        if @booking.approved?
          if @booking.update(checked_in_at: Time.current)
            render json: { message: "Checked in successfully", booking: @booking }, status: :ok
          else
            render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "Only approved bookings can be checked in" }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/bookings/release_expired
      def release_expired
        authorize! :manage, Booking
        released_count = Booking.release_expired_bookings
        render json: { message: "Successfully released #{released_count} expired bookings" }, status: :ok
      end

      # PATCH/PUT /api/v1/bookings/:id
      def update
        @booking.performer_id = current_user.id
        if @booking.update(booking_params)
          render json: @booking
        else
          render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/bookings/:id
      def destroy
        @booking.destroy
        head :no_content
      end

      private

      def booking_params
        params.permit(:resource_id, :start_time, :end_time, :status, :admin_note, :allow_smaller_capacity)
      end
    end
  end
end
