require 'swagger_helper'

RSpec.describe 'Reports API', type: :request, openapi_spec: 'v1/swagger.yaml' do
  let(:admin) { create(:admin) }
  # Global security is defined in swagger_helper, so provide a default Authorization header
  let(:'Authorization') { nil }

  path '/reports/top-products-by-category' do
    get 'Top products by category' do
      tags 'Reports'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :limit, in: :query, schema: { type: :integer, minimum: 1 }
      # Provide a safe default to avoid empty string issues in Integer()
      let(:limit) { 3 }

      response '200', 'ok' do
        # Set the Authorization header value directly to avoid constant/method ambiguity
        let(:'Authorization') { "Bearer #{JsonWebToken.jwt_encode({ admin_id: admin.id })}" }
        before do
          cat = create(:category)
          prod = create(:product, categories: [ cat ])
          create(:purchase, product: prod)
        end
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { nil }
        run_test!
      end
    end
  end

  path '/reports/top-revenue-products-by-category' do
    get 'Top revenue products by category' do
      tags 'Reports'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :limit, in: :query, schema: { type: :integer, minimum: 1 }
      # Provide a safe default to avoid empty string issues in Integer()
      let(:limit) { 3 }

      response '200', 'ok' do
        # Set the Authorization header value directly to avoid constant/method ambiguity
        let(:'Authorization') { "Bearer #{JsonWebToken.jwt_encode({ admin_id: admin.id })}" }
        before do
          cat = create(:category)
          prod = create(:product, categories: [ cat ])
          create(:purchase, product: prod)
        end
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'Authorization') { nil }
        run_test!
      end
    end
  end
end
