require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:user)).to be_valid
      puts "✅ PASS: Valid user can be created (Normal Case)"
    end

    it "is invalid without an email" do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
      puts "✅ PASS: User invalid without email (Edge Case: Required Field)"
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "test@example.com")
      user2 = build(:user, email: "test@example.com")
      expect(user2).not_to be_valid
      expect(user2.errors[:email]).to include("has already been taken")
      puts "✅ PASS: Email uniqueness enforced (Edge Case: Duplicate Data)"
    end

    it "is invalid without employee_id" do
      user = build(:user, employee_id: nil)
      expect(user).not_to be_valid
      puts "✅ PASS: User invalid without employee_id (Edge Case: Required Field)"
    end
  end

  describe "roles" do
    it "has a default role of employee" do
      user = create(:user)
      expect(user.role).to eq("employee")
      puts "✅ PASS: Default role assigned correctly (Normal Case)"
    end

    it "can be an admin" do
      user = create(:user, :admin)
      expect(user.role).to eq("admin")
      puts "✅ PASS: Admin role assigned correctly (Normal Case)"
    end
  end
end
