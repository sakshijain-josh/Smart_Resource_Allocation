FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    role { 'employee' }
    sequence(:employee_id) { |n| "EMP#{n}" }

    trait :admin do
      role { 'admin' }
    end
  end

  factory :resource do
    sequence(:name) { |n| "Resource #{n}" }
    description { Faker::Company.bs }
    location { "Floor #{rand(1..5)}" }
    resource_type { 'meeting-room' }
    is_active { true }
    properties { { capacity: rand(2..20) } }

    trait :turf do
      resource_type { 'turf' }
    end
  end

  factory :booking do
    association :user
    association :resource
    # Set to a Wednesday at 10 AM in the future (Jan 6, 2027)
    start_time { Time.utc(2027, 1, 6, 10, 0, 0) }
    end_time { Time.utc(2027, 1, 6, 11, 0, 0) }
    status { :pending }
    allow_smaller_capacity { false }

    trait :approved do
      status { :approved }
      approved_at { Time.current }
    end

    trait :checked_in do
      approved
      status { :checked_in }
      checked_in_at { Time.current }
    end
  end

  factory :holiday do
    name { 'Public Holiday' }
    holiday_date { Date.today + 7.days }
  end

  factory :audit_log do
    association :booking
    association :resource
    action { 'Status Update' }
    old_status { :pending }
    new_status { :approved }
    message { 'Booking approved by admin' }
  end

  factory :notification do
    association :user
    association :booking
    channel { 'email' }
    notification_type { 'booking_approved' }
    sent_at { Time.current }
    is_read { false }
  end
end
