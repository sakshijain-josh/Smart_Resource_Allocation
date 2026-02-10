require 'swagger_helper'

RSpec.describe 'api/v1/reports', type: :request do
  path '/api/v1/reports/resource_usage' do
    get 'Retrieves resource usage report (Admin only)' do
      tags 'Reports'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/ResourceUsageReport'

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in admin }
        run_test!
      end

      response '403', 'forbidden (Employee cannot access)' do
        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in employee }
        run_test!
      end
    end
  end

  path '/api/v1/reports/user_bookings' do
    get 'Retrieves user bookings summary (Admin only)' do
      tags 'Reports'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/UserBookingsReport'

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in admin }
        run_test!
      end
    end
  end

  path '/api/v1/reports/peak_hours' do
    get 'Retrieves peak hours analysis (Admin only)' do
      tags 'Reports'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/PeakHoursReport'

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in admin }
        run_test!
      end
    end
  end

  path '/api/v1/reports/utilization' do
    get 'Retrieves resource utilization report (Admin only)' do
      tags 'Reports'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/UtilizationReport'

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in admin }
        run_test!
      end
    end
  end
end
