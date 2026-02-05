require "test_helper"

class HolidayTest < ActiveSupport::TestCase
  test "valid holiday" do
    holiday = build(:holiday)
    assert holiday.valid?
    puts "✅ PASS: Valid holiday can be created"
  end

  test "as_json includes necessary fields" do
    holiday = create(:holiday)
    json = holiday.as_json
    assert_equal holiday.name, json[:name]
    assert_equal holiday.holiday_date, json[:holiday_date]
    puts "✅ PASS: Holiday JSON structure is correct"
  end
end
