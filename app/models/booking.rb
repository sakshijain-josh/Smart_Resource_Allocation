class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :resource
  
  
  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    expired: 3,
    auto_released: 4,
    cancelled_by_user: 5
  }

end
