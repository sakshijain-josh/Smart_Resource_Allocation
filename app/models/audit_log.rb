class AuditLog < ApplicationRecord
  belongs_to :booking
  belongs_to :resource
end
