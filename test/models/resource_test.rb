require "test_helper"

class ResourceTest < ActiveSupport::TestCase
  test "valid resource" do
    resource = build(:resource, resource_type: 'meeting-room')
    assert resource.valid?
    puts "✅ PASS: Valid resource can be created"
  end

  test "invalid without name" do
    resource = build(:resource, name: nil, resource_type: 'meeting-room')
    assert_not resource.valid?
    puts "✅ PASS: Resource invalid without name"
  end

  test "invalid with duplicate name" do
    create(:resource, name: "Meeting Room A", resource_type: 'meeting-room')
    resource2 = build(:resource, name: "Meeting Room A", resource_type: 'meeting-room')
    assert_not resource2.valid?
    puts "✅ PASS: Resource name must be unique"
  end

  test "only one Turf resource allowed" do
    create(:resource, resource_type: 'turf')
    turf2 = build(:resource, resource_type: 'turf')
    assert_not turf2.valid?
    assert_includes turf2.errors[:resource_type], 'only one Turf resource is allowed'
    puts "✅ PASS: Turf uniqueness enforced (Edge Case: Singleton Resource)"
  end

  test "available_slots returns correct structure" do
    resource = create(:resource)
    slots = resource.available_slots(Date.today)
    assert_kind_of Array, slots
    assert slots.present?
    assert_respond_to slots.first, :[]
    puts "✅ PASS: available_slots returns an array of slots"
  end

  test "available_slots detects conflicts" do
    resource = create(:resource)
    user = create(:user)
    # Create an approved booking from 10 AM to 11 AM
    start_time = Time.utc(Date.today.year, Date.today.month, Date.today.day, 10, 0, 0)
    end_time = Time.utc(Date.today.year, Date.today.month, Date.today.day, 11, 0, 0)
    create(:booking, resource: resource, user: user, start_time: start_time, end_time: end_time, status: :approved)

    slots = resource.available_slots(Date.today)
    ten_am_slot = slots.find { |s| s[:start_time].hour == 10 }
    
    assert_not ten_am_slot[:available], "Slot at 10 AM should be booked"
    assert_equal user.name, ten_am_slot[:booked_by]
    puts "✅ PASS: available_slots correctly identifies overlapping approved bookings"
  end
end
