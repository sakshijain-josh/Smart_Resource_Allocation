require "rails_helper"

RSpec.describe AuditLog, type: :model do
  it "is valid with valid attributes" do
    expect(build(:audit_log)).to be_valid
  end
end
