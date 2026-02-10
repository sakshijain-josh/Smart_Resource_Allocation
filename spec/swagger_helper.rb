# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve Swagger files, you'll need
  # to ensure that it's configured to serve files from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to
  # the relevant spec, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Resource Allocator API V1',
        version: 'v1',
        description: 'API for Managing Resources and Bookings'
      },
      paths: {},
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              employee_id: { type: :string },
              name: { type: :string },
              email: { type: :string },
              role: { type: :string, enum: %w[employee admin] },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id employee_id name email role]
          },
          Resource: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              resource_type: { type: :string, enum: %w[meeting-room laptop phone turf] },
              description: { type: :string, nullable: true },
              location: { type: :string, nullable: true },
              is_active: { type: :boolean },
              properties: { type: :object, nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id name resource_type is_active]
          },
          Booking: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              employee_id: { type: :string, nullable: true },
              employee_name: { type: :string, nullable: true },
              resource_id: { type: :integer },
              resource_name: { type: :string, nullable: true },
              status: { type: :string, enum: %w[pending approved rejected expired auto_released cancelled_by_user] },
              start_time: { type: :string, format: 'date-time' },
              end_time: { type: :string, format: 'date-time' },
              approved_at: { type: :string, format: 'date-time', nullable: true },
              cancelled_at: { type: :string, format: 'date-time', nullable: true },
              checked_in_at: { type: :string, format: 'date-time', nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id user_id resource_id status start_time end_time]
          },
          AuthResponse: {
            type: :object,
            properties: {
              token: { type: :string },
              user: { '$ref' => '#/components/schemas/User' }
            },
            required: %w[token user]
          },
          PaginatedUsers: {
            type: :object,
            properties: {
              users: { type: :array, items: { '$ref' => '#/components/schemas/User' } },
              total: { type: :integer },
              limit: { type: :integer },
              offset: { type: :integer },
              has_more: { type: :boolean }
            },
            required: %w[users total limit offset has_more]
          },
          PaginatedResources: {
            type: :object,
            properties: {
              resources: { type: :array, items: { '$ref' => '#/components/schemas/Resource' } },
              total: { type: :integer },
              limit: { type: :integer },
              offset: { type: :integer },
              has_more: { type: :boolean }
            },
            required: %w[resources total limit offset has_more]
          },
          PaginatedBookings: {
            type: :object,
            properties: {
              bookings: { type: :array, items: { '$ref' => '#/components/schemas/Booking' } },
              total: { type: :integer },
              limit: { type: :integer },
              offset: { type: :integer },
              has_more: { type: :boolean }
            },
            required: %w[bookings total limit offset has_more]
          },
          ResourceUsageReport: {
            type: :object,
            properties: {
              report_type: { type: :string },
              data: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    resource_id: { type: :integer },
                    resource_name: { type: :string },
                    resource_type: { type: :string },
                    total_bookings: { type: :integer }
                  }
                }
              }
            }
          },
          UserBookingsReport: {
            type: :object,
            properties: {
              report_type: { type: :string },
              data: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    user_id: { type: :integer },
                    user_name: { type: :string },
                    total_approved_bookings: { type: :integer }
                  }
                }
              }
            }
          },
          PeakHoursReport: {
            type: :object,
            properties: {
              report_type: { type: :string },
              data: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    hour: { type: :string },
                    bookings: { type: :integer }
                  }
                }
              }
            }
          },
          UtilizationReport: {
            type: :object,
            properties: {
              report_type: { type: :string },
              over_utilised: { type: :array, items: { '$ref' => '#/components/schemas/Resource' } },
              under_utilised: { type: :array, items: { '$ref' => '#/components/schemas/Resource' } },
              summary: {
                type: :object,
                properties: {
                  total_resources: { type: :integer },
                  over_utilised_count: { type: :integer },
                  under_utilised_count: { type: :integer }
                }
              }
            }
          },
          error: {
            type: :object,
            properties: {
              error: { type: :string },
              message: { type: :string }
            }
          },
          errors: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string }
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs stack chart below will take precedence over this option.
  # config.openapi_format = :json
end
