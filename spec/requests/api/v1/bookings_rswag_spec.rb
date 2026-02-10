require 'swagger_helper'

RSpec.describe 'api/v1/bookings', type: :request do
  path '/api/v1/bookings' do
    get 'Lists all bookings' do
      tags 'Bookings'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :status, in: :query, type: :string, required: false
      parameter name: :resource_id, in: :query, type: :integer, required: false
      parameter name: :limit, in: :query, type: :integer, required: false
      parameter name: :offset, in: :query, type: :integer, required: false

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/PaginatedBookings'

        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in employee }
        run_test!
      end
    end

    post 'Creates a booking' do
      tags 'Bookings'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :booking_params, in: :body, schema: {
        type: :object,
        properties: {
          resource_id: { type: :integer },
          start_time: { type: :string, format: 'date-time' },
          end_time: { type: :string, format: 'date-time' }
        },
        required: [ 'resource_id', 'start_time', 'end_time' ]
      }

      response '201', 'booking created' do
        schema '$ref' => '#/components/schemas/Booking'

        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:resource) { create(:resource) }
        let(:booking_params) { { resource_id: resource.id, start_time: Time.current + 1.hour, end_time: Time.current + 2.hours } }
        before { sign_in employee }
        run_test!
      end

      response '422', 'unprocessable entity (overlap)' do
        # This will depend on actual validation logic, but here's the spec for it
        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:resource) { create(:resource) }
        let!(:existing_booking) { create(:booking, :approved, resource: resource, start_time: Time.current + 1.hour, end_time: Time.current + 2.hours) }
        let(:booking_params) { { resource_id: resource.id, start_time: Time.current + 1.hour, end_time: Time.current + 2.hours } }
        before { sign_in employee }
        run_test!
      end
    end
  end

  path '/api/v1/bookings/{id}/check_in' do
    parameter name: :id, in: :path, type: :string

    post 'Checks in to an approved booking' do
      tags 'Bookings'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'check-in successful' do
        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:booking) { create(:booking, :approved, user: employee) }
        let(:id) { booking.id }
        before { sign_in employee }
        run_test!
      end

      response '403', 'forbidden (not approved or wrong user)' do
        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:booking) { create(:booking, status: :pending, user: employee) }
        let(:id) { booking.id }
        before { sign_in employee }
        run_test!
      end
    end
  end

  path '/api/v1/bookings/release_expired' do
    post 'Releases expired bookings (Admin only)' do
      tags 'Bookings'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'release successful' do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in admin }
        run_test!
      end

      response '403', 'forbidden (Employee cannot trigger)' do
        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in employee }
        run_test!
      end
    end
  end
end
