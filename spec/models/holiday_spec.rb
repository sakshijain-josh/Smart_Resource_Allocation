require "rails_helper"

RSpec.describe Holiday, type: :model do
  it "is valid with valid attributes" do
    expect(build(:holiday)).to be_valid
  end

  describe "#as_json" do
    it "includes necessary fields" do
      holiday = create(:holiday)
      json = holiday.as_json.symbolize_keys
      expect(json[:name]).to eq(holiday.name)
      expect(json[:holiday_date]).to eq(holiday.holiday_date)
    end
  end
end
