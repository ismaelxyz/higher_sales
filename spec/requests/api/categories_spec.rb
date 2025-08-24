require 'swagger_helper'

RSpec.describe 'Categories API', type: :request, openapi_spec: 'v1/swagger.yaml' do
  let(:admin) { create(:admin) }
  # Global security is defined in swagger_helper, so provide a default Authorization header
  let(:'Authorization') { nil }

  path '/categories' do
    get 'List categories' do
      tags 'Categories'
      produces 'application/json'
      response '200', 'ok' do
        before { create(:category) }
        run_test!
      end
    end

    post 'Create category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string }, description: { type: :string } },
        required: %w[name]
      }
  let(:category) { nil }

      response '201', 'created' do
  # Provide the Authorization header directly in the example
  let(:'Authorization') { "Bearer #{JsonWebToken.jwt_encode({ admin_id: admin.id })}" }
        let(:category) { { name: 'New', description: 'desc' } }
        run_test!
      end

      response '401', 'unauthorized' do
  let(:'Authorization') { nil }
        let(:category) { { name: 'New' } }
        run_test!
      end
    end
  end

  path '/categories/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Show category' do
      tags 'Categories'
      produces 'application/json'
      response '200', 'ok' do
        let(:id) { create(:category).id }
        run_test!
      end
    end

    put 'Update category' do
      tags 'Categories'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: { name: { type: :string }, description: { type: :string } }
      }
  let(:category) { nil }

      response '200', 'updated' do
  # Provide the Authorization header directly in the example
  let(:'Authorization') { "Bearer #{JsonWebToken.jwt_encode({ admin_id: admin.id })}" }
        let(:id) { create(:category, name: 'Old').id }
        let(:category) { { name: 'Updated' } }
        run_test!
      end

      response '401', 'unauthorized' do
  let(:'Authorization') { nil }
        let(:id) { create(:category).id }
        let(:category) { { name: 'Updated' } }
        run_test!
      end
    end

    delete 'Delete category' do
      tags 'Categories'
      security [ bearerAuth: [] ]

      response '204', 'deleted' do
  # Provide the Authorization header directly in the example
  let(:'Authorization') { "Bearer #{JsonWebToken.jwt_encode({ admin_id: admin.id })}" }
        let(:id) { create(:category).id }
        run_test!
      end

      response '401', 'unauthorized' do
  let(:'Authorization') { nil }
        let(:id) { create(:category).id }
        run_test!
      end
    end
  end
end
