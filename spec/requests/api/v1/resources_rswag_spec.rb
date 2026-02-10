require 'swagger_helper'

RSpec.describe 'api/v1/resources', type: :request do
  path '/api/v1/resources' do
    get 'Lists all resources' do
      tags 'Resources'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :resource_type, in: :query, type: :string, required: false
      parameter name: :location, in: :query, type: :string, required: false
      parameter name: :is_active, in: :query, type: :boolean, required: false
      parameter name: :limit, in: :query, type: :integer, required: false
      parameter name: :offset, in: :query, type: :integer, required: false

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/PaginatedResources'

        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in employee }
        run_test!
      end
    end

    post 'Creates a resource (Admin only)' do
      tags 'Resources'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :resource_params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          resource_type: { type: :string },
          location: { type: :string }
        },
        required: [ 'name', 'resource_type' ]
      }

      response '201', 'resource created' do
        schema '$ref' => '#/components/schemas/Resource'

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:resource_params) { { name: 'New Meeting Room', resource_type: 'meeting-room', location: 'Floor 1' } }
        before { sign_in admin }
        run_test!
      end

      response '403', 'forbidden (Employee cannot create)' do
        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:resource_params) { { name: 'Restricted Room', resource_type: 'meeting-room' } }
        before { sign_in employee }
        run_test!
      end
    end
  end

  path '/api/v1/resources/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Retrieves a resource' do
      tags 'Resources'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/Resource'

        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:resource) { create(:resource) }
        let(:id) { resource.id }
        before { sign_in employee }
        run_test!
      end
    end

    patch 'Updates a resource (Admin only)' do
      tags 'Resources'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :resource_params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          resource_type: { type: :string },
          location: { type: :string }
        }
      }

      response '200', 'resource updated' do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:resource) { create(:resource) }
        let(:id) { resource.id }
        let(:resource_params) { { name: 'Updated Room Name' } }
        before { sign_in admin }
        run_test!
      end
    end

    delete 'Deletes a resource (Admin only)' do
      tags 'Resources'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '204', 'resource deleted' do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:resource) { create(:resource) }
        let(:id) { resource.id }
        before { sign_in admin }
        run_test!
      end
    end
  end

  path '/api/v1/resources/{id}/availability' do
    parameter name: :id, in: :path, type: :string
    get 'Checks resource availability' do
      tags 'Resources'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :date, in: :query, type: :string, format: :date, description: 'Date to check availability (YYYY-MM-DD)', required: false
      parameter name: :duration, in: :query, type: :number, description: 'Duration in hours', required: false

      response '200', 'successful' do
        schema type: :object,
               properties: {
                 available_slots: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       start_time: { type: :string, format: 'date-time' },
                       end_time: { type: :string, format: 'date-time' }
                     }
                   }
                 }
               }

        let(:employee) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: employee.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:resource) { create(:resource) }
        let(:id) { resource.id }
        before { sign_in employee }
        run_test!
      end
    end
  end
end
