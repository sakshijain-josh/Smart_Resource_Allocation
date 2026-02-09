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

  # GET /api/v1/reports/utilization
  def utilization
    # Count approved and auto_released bookings per resource
    usage_counts = Booking.where(status: [ :approved, :auto_released ])
                          .group(:resource_id)
                          .count

    all_resources = Resource.all
    resource_data = all_resources.map do |resource|
      {
        resource_id: resource.id,
        resource_name: resource.name,
        resource_type: resource.resource_type,
        total_bookings: usage_counts[resource.id] || 0
      }
    end

    # Sort by total bookings descending
    sorted_resources = resource_data.sort_by { |r| -r[:total_bookings] }

    # Define thresholds
    # Over-utilized: Top 25% (at least 1 booking)
    # Under-utilized: Bottom 25% (or 0 bookings)
    
    threshold_count = (sorted_resources.size * 0.25).ceil
    threshold_count = 1 if threshold_count < 1 && sorted_resources.size > 0

    over_utilised = sorted_resources.first(threshold_count).select { |r| r[:total_bookings] > 0 }
    under_utilised = sorted_resources.last(threshold_count)

    render json: {
      report_type: "resource_utilization",
      over_utilised: over_utilised,
      under_utilised: under_utilised,
      summary: {
        total_resources: all_resources.size,
        over_utilised_count: over_utilised.size,
        under_utilised_count: under_utilised.size
      }
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
