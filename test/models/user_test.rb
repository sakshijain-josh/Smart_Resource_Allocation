require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = build(:user)
    assert user.valid?, "Expected user to be valid, but errors: #{user.errors.full_messages}"
    puts "✅ PASS: Valid user can be created"
  end

  test "invalid without email" do
    user = build(:user, email: nil)
    assert_not user.valid?, "User should be invalid without an email"
    assert_includes user.errors[:email], "can't be blank"
    puts "✅ PASS: User invalid without email (Edge Case: Required Field)"
  end

  test "invalid with duplicate email" do
    create(:user, email: "test@example.com")
    user2 = build(:user, email: "test@example.com")
    assert_not user2.valid?
    assert_includes user2.errors[:email], "has already been taken"
    puts "✅ PASS: Email uniqueness enforced (Edge Case: Duplicate Data)"
  end

  test "invalid without employee_id" do
    user = build(:user, employee_id: nil)
    assert_not user.valid?
    puts "✅ PASS: User invalid without employee_id"
  end

  test "default role is employee" do
    user = create(:user)
    assert_equal "employee", user.role
    puts "✅ PASS: Default role assigned correctly"
  end

  test "can be admin" do
    user = create(:user, :admin)
    assert_equal "admin", user.role
    puts "✅ PASS: Admin role assigned correctly"
  end
end
