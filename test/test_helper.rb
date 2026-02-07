require "simplecov"
SimpleCov.start "rails" do
  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/test/"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "warden"
require "devise/jwt/test_helpers"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    include Devise::Test::IntegrationHelpers
    include Warden::Test::Helpers

    Warden.test_mode!

    # helper for JWT auth in integration tests
    def auth_headers(user)
      headers = { "Accept" => "application/json", "Content-Type" => "application/json" }
      Devise::JWT::TestHelpers.auth_headers(headers, user)
    end
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
