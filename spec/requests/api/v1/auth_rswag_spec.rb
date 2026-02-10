require 'swagger_helper'

RSpec.describe 'api/v1/auth', type: :request do
  path '/api/v1/auth/login' do
    post 'Logs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'legacythreads11@gmail.com' },
          password: { type: :string, example: '123456789' }
        },
        required: [ 'email', 'password' ]
      }

      response '200', 'login successful' do
        schema '$ref' => '#/components/schemas/AuthResponse'

        let(:user_record) { create(:user, email: 'legacythreads11@gmail.com', password: '123456789') }
        let(:user) { { email: user_record.email, password: '123456789' } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:user) { { email: 'wrong@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end

  

  path '/api/v1/auth/logout' do
    delete 'Logs out a user' do
      tags 'Authentication'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'logout successful' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: user.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        # Note: devise-jwt might have different logic, but this is a placeholder for test
        # In actual test, we might need to use Devise helpers
        before { sign_in user }
        run_test!
      end
    end
  end

  path '/api/v1/auth/me' do
    get 'Returns current user information' do
      tags 'Authentication'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/User'

        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{JWT.encode({ user_id: user.id }, Rails.application.credentials.fetch(:secret_key_base))}" }
        before { sign_in user }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
