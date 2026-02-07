# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      # Admins can manage everything
      can :manage, :all
    elsif user.employee?
      # === Booking Permissions ===
      # Employees can read all bookings (to see availability)
      can :read, Booking

      # Employees can create bookings
      can :create, Booking

      # Employees can update their own pending bookings
      can :update, Booking, user_id: user.id, status: "pending"

      # Employees can cancel their own pending or approved bookings
      can :destroy, Booking, user_id: user.id, status: [ "pending", "approved" ]

      # Employees can check-in to their own approved bookings
      can :check_in, Booking, user_id: user.id, status: "approved"

      # === Resource Permissions ===
      # Employees can read resources (to see what's available)
      can [ :read, :availability ], Resource

      # === User Permissions ===
      # Employees can read  their own user profile
      can :read, User, id: user.id

      # === Holiday Permissions ===
      # Employees can read holidays
      can :read, Holiday

      # === Notification Permissions ===
      # Employees can read their own notifications
      can :read, Notification, user_id: user.id
    end

    # Define abilities for other roles or specific scenarios here
  end
end
