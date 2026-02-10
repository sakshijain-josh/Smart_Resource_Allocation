require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  path '/api/v1/users' do
    get 'Lists all users (Admin only)' do
      tags 'Users'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :limit, in: :query, type: :integer, description: 'Limit number of users (default 10)', required: false
      parameter name: :offset, in: :query, type: :integer, description: 'Offset for pagination (default 0)', required: false

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/PaginatedUsers'

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in admin }
        run_test!
      end

      response '403', 'forbidden' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: user.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in user }
        run_test!
      end
    end

    post 'Creates a user (Admin only)' do
      tags 'Users'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          employee_id: { type: :string },
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          role: { type: :string, enum: [ 'employee', 'admin' ] }
        },
        required: [ 'employee_id', 'name', 'email', 'password', 'role' ]
      }

      response '201', 'user created' do
        schema type: :object,
               properties: {
                 message: { type: :string },
                 user: { '$ref' => '#/components/schemas/User' }
               }

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:user_params) { { employee_id: 'EMP123', name: 'John Doe', email: 'john@example.com', password: 'password', role: 'employee' } }
        before { sign_in admin }
        run_test!
      end
    end
  end

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :string

    delete 'Deletes a user (Admin only)' do
      tags 'Users'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'user deleted' do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:emp) { create(:user) }
        let(:id) { emp.id }
        before { sign_in admin }
        run_test!
      end

      response '403', 'forbidden (cannot delete self)' do
        let(:admin) { create(:user, :admin) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: admin.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        let(:id) { admin.id }
        before { sign_in admin }
        run_test!
      end
    end
  end
end
