require "rails_helper"

RSpec.describe Notification, type: :model do
  it "is valid with valid attributes" do
    expect(build(:notification)).to be_valid
  end
end
