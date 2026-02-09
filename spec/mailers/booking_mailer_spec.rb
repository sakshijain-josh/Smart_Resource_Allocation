require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:resource) { create(:resource) }
  let(:booking) { create(:booking, user: user, resource: resource) }

  describe "request_received" do
    let(:mail) { BookingMailer.request_received(booking) }

    it "renders the headers" do
      expect(mail.subject).to include("New Booking Request")
      expect(mail.to).to eq([BookingMailer::ADMIN_EMAIL])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include(user.name)
      expect(mail.body.encoded).to include(resource.name)
    end
  end

  describe "status_updated" do
    let(:mail) { BookingMailer.status_updated(booking) }

    it "renders the headers" do
      expect(mail.subject).to include("Booking Update")
      expect(mail.to).to eq([user.email])
    end
  end
end
