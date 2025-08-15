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

  describe 'GET /reports/top-revenue-products-by-category' do
    let!(:admin) { create(:admin) }
    let!(:category) { create(:category, name: 'Cat Rev') }
    let!(:product1) { create(:product, name: 'Rev1', price: 10, categories: [ category ]) }
    let!(:product2) { create(:product, name: 'Rev2', price: 5, categories: [ category ]) }
    let!(:client) { create(:client) }

    before do
      # product1 sold 1 time ($10), product2 sold 3 times ($15)
      create(:purchase, client: client, product: product1)
      3.times { create(:purchase, client: client, product: product2) }
    end

    it 'requires authentication' do
      get '/reports/top-revenue-products-by-category'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns products ordered by revenue when authorized' do
      token = JsonWebToken.jwt_encode({ admin_id: admin.id })
      get '/reports/top-revenue-products-by-category', headers: { 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      first_product = json.first['products'].first
      expect(first_product['name']).to eq('Rev2')
      expect(first_product['total_revenue']).to eq(15.0)
    end
  end
end
