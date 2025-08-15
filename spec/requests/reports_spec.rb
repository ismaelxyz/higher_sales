require 'rails_helper'

RSpec.describe 'Reports', type: :request do
  describe 'GET /reports/top-products-by-category' do
    let!(:admin) { create(:admin) }
  let!(:category) { create(:category, name: 'Cat 1') }
    let!(:product1) { create(:product, name: 'Prod1', categories: [ category ]) }
    let!(:product2) { create(:product, name: 'Prod2', categories: [ category ]) }
    let!(:client) { create(:client) }

    before do
      create(:purchase, client: client, product: product1)
      create(:purchase, client: client, product: product1)
      create(:purchase, client: client, product: product2)
    end

    it 'requires authentication' do
      get '/reports/top-products-by-category'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns top products when authorized' do
      token = JsonWebToken.jwt_encode({ admin_id: admin.id })
      get '/reports/top-products-by-category', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first['products'].first['name']).to eq('Prod1')
      expect(json.first['products'].first['total_sold']).to eq(2)
    end
  end
end
