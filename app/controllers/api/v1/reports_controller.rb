class Api::V1::ReportsController < ApplicationController
  before_action :require_admin!

  # GET /api/v1/reports/resource_usage
  def resource_usage
    # Count approved and auto_released bookings per resource
    usage = Booking.where(status: [ :approved, :auto_released ])
                   .group(:resource_id)
                   .count
                   .map do |resource_id, count|
                     resource = Resource.find(resource_id)
                     {
                       resource_id: resource_id,
                       resource_name: resource.name,
                       resource_type: resource.resource_type,
                       total_bookings: count
                     }
                   end

    render json: {
      report_type: "resource_usage",
      data: usage.sort_by { |u| -u[:total_bookings] }
    }
  end

  # GET /api/v1/reports/user_bookings
  def user_bookings
    # Count approved bookings per user
    user_data = Booking.where(status: [ :approved, :auto_released ])
                       .group(:user_id)
                       .count
                       .map do |user_id, count|
                         user = User.find(user_id)
                         {
                           user_id: user_id,
                           user_name: user.name,
                           total_approved_bookings: count
                         }
                       end

    render json: {
      report_type: "user_bookings_summary",
      data: user_data.sort_by { |u| -u[:total_approved_bookings] }
    }
  end

  # GET /api/v1/reports/peak_hours
  def peak_hours
    # Analyze start_time hours for approved bookings
    hour_counts = Booking.where(status: [ :approved, :auto_released ])
                         .pluck(:start_time) # fevthes single coumn while pick fetch single row from db
                         .map { |t| t.hour }
                         .tally # Har value kitni baar aayi, uska count bata do.
                         .map { |hour, count| { hour: "#{hour}:00", bookings: count } }

    render json: {
      report_type: "peak_hours_analysis",
      data: hour_counts.sort_by { |h| h[:hour].to_i }
    }
  end

  private

  def require_admin!
    unless current_user&.admin?
      render json: {
        error: "Forbidden",
        message: "You do not have permission to access reports"
      }, status: :forbidden
    end
  end
end
