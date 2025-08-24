require 'swagger_helper'

RSpec.describe 'Purchases API', type: :request, openapi_spec: 'v1/swagger.yaml' do
  let(:admin) { create(:admin) }
  # Global security is defined in swagger_helper, so provide a default Authorization header
  let(:'Authorization') { nil }

  path '/purchases' do
    get 'List purchases' do
      tags 'Purchases'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :from, in: :query, schema: { type: :string, format: :date }
      parameter name: :to, in: :query, schema: { type: :string, format: :date }
      parameter name: :category_id, in: :query, schema: { type: :integer }
      parameter name: :client_id, in: :query, schema: { type: :integer }
      parameter name: :admin_id, in: :query, schema: { type: :integer }
      parameter name: :page, in: :query, schema: { type: :integer, minimum: 1 }
      parameter name: :per_page, in: :query, schema: { type: :integer, minimum: 1, maximum: 50 }
      parameter name: :include_products, in: :query, schema: { type: :boolean }
      parameter name: :include_categories, in: :query, schema: { type: :boolean }

  # Defaults for optional params (rswag requires defining them)
  let(:from) { nil }
  let(:to) { nil }
  let(:category_id) { nil }
  let(:client_id) { nil }
  let(:admin_id) { nil }
  let(:page) { nil }
  let(:per_page) { nil }
  let(:include_products) { nil }
  let(:include_categories) { nil }

  response '200', 'ok' do
        schema type: :object,
               properties: {
                 data: { type: :array, items: { type: :object } },
                 _metadata: {
                   type: :object,
                   properties: {
                     page: { type: :integer },
                     per_page: { type: :integer },
                     total: { type: :integer },
                     total_pages: { type: :integer }
                   }
                 }
               }

  let(:'Authorization') { "Bearer #{JsonWebToken.jwt_encode({ admin_id: admin.id })}" }
        before do
          client = create(:client)
          create(:purchase, client: client)
        end
        run_test!
      end

      response '401', 'unauthorized' do
  let(:'Authorization') { nil }
        run_test!
      end
    end
  end

  path '/purchases/counts' do
    get 'Counts of purchases grouped by time bucket' do
      tags 'Purchases'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :granularity, in: :query, required: true, schema: { type: :string, enum: %w[hour day week year] }
      parameter name: :from, in: :query, schema: { type: :string, format: :date }
      parameter name: :to, in: :query, schema: { type: :string, format: :date }
      parameter name: :category_id, in: :query, schema: { type: :integer }
      parameter name: :client_id, in: :query, schema: { type: :integer }
      parameter name: :admin_id, in: :query, schema: { type: :integer }

  # Define defaults for optional params and a sane default granularity
  let(:granularity) { 'day' }
  let(:from) { nil }
  let(:to) { nil }
  let(:category_id) { nil }
  let(:client_id) { nil }
  let(:admin_id) { nil }

  response '200', 'ok' do
  let(:'Authorization') { "Bearer #{JsonWebToken.jwt_encode({ admin_id: admin.id })}" }
        before do
          client = create(:client)
          create(:purchase, client: client)
        end
        run_test!
      end

      response '422', 'invalid granularity' do
  let(:'Authorization') { "Bearer #{JsonWebToken.jwt_encode({ admin_id: admin.id })}" }
        let(:granularity) { 'minute' }
        run_test!
      end

      response '401', 'unauthorized' do
  let(:'Authorization') { nil }
        run_test!
      end
    end
  end
end
