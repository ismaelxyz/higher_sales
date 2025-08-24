require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request, openapi_spec: 'v1/swagger.yaml' do
  # Global security is defined in swagger_helper, so provide a default Authorization header
  let(:'Authorization') { nil }
  path '/auth/login' do
    post 'Authenticate admin and get JWT' do
      tags 'Auth'
      consumes 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string }
        },
        required: %w[email password]
      }

      response '200', 'authenticated' do
        schema type: :object,
               properties: {
                 token: { type: :string },
                 admin: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string },
                     email: { type: :string }
                   }
                 }
               },
               required: %w[token admin]

        let!(:admin) { create(:admin, password: 'secret123', password_confirmation: 'secret123') }
        let(:credentials) { { email: admin.email, password: 'secret123' } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let!(:admin) { create(:admin, password: 'secret123', password_confirmation: 'secret123') }
        let(:credentials) { { email: admin.email, password: 'wrong' } }
        run_test!
      end
    end
  end
end
