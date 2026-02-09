require "rails_helper"

RSpec.describe Resource, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:resource, resource_type: "meeting-room")).to be_valid
      puts "✅ PASS: Valid resource can be created (Normal Case)"
    end

    it "is invalid without a name" do
      resource = build(:resource, name: nil, resource_type: "meeting-room")
      expect(resource).not_to be_valid
      puts "✅ PASS: Resource invalid without name (Edge Case: Required Field)"
    end

    it "is invalid with a duplicate name" do
      create(:resource, name: "Meeting Room A", resource_type: "meeting-room")
      resource2 = build(:resource, name: "Meeting Room A", resource_type: "meeting-room")
      expect(resource2).not_to be_valid
      puts "✅ PASS: Resource name must be unique (Edge Case: Duplicate Data)"
    end

    it "allows only one Turf resource" do
      create(:resource, resource_type: "turf")
      turf2 = build(:resource, resource_type: "turf")
      expect(turf2).not_to be_valid
      expect(turf2.errors[:resource_type]).to include("only one Turf resource is allowed")
      puts "✅ PASS: Turf uniqueness enforced (Edge Case: Singleton Resource)"
    end
  end

  describe "#available_slots" do
    let(:resource) { create(:resource) }

    it "returns an array of slots" do
      slots = resource.available_slots(Date.today)
      expect(slots).to be_an(Array)
      expect(slots).not_to be_empty
      puts "✅ PASS: available_slots returns an array of slots (Normal Case)"
    end

    it "detects conflicts with approved bookings" do
      user = create(:user)
      # Create an approved booking from 10 AM to 11 AM on a future date
      date = Date.new(2027, 1, 6) # Wednesday
      start_time = Time.zone.local(date.year, date.month, date.day, 10, 0, 0)
      end_time = Time.zone.local(date.year, date.month, date.day, 11, 0, 0)
      create(:booking, resource: resource, user: user, start_time: start_time, end_time: end_time, status: :approved)

      slots = resource.available_slots(date)
      ten_am_slot = slots.find { |s| Time.zone.parse(s[:start_time]).hour == 10 }

      expect(ten_am_slot[:available]).to be false
      expect(ten_am_slot[:booked_by]).to eq(user.name)
      puts "✅ PASS: available_slots correctly identifies overlapping approved bookings (Edge Case: Slot Conflict)"
    end
  end
end
