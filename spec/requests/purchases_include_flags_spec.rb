require 'rails_helper'

RSpec.describe 'Purchases include flags', type: :request do
  let!(:admin) { create(:admin) }
  let!(:token) { JsonWebToken.jwt_encode({ admin_id: admin.id }) }
  let!(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let!(:category) { create(:category, name: 'Cat A') }
  let!(:product) { create(:product, categories: [ category ]) }
  let!(:client) { create(:client) }
  let!(:purchase) { create(:purchase, client: client, products: [ product ]) }

  it 'omits products when include_products=false' do
    get '/purchases', params: { include_products: false }, headers: headers
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json['data']).not_to be_empty
    expect(json['data'].first).not_to have_key('products')
  end

  it 'includes products but omits categories when include_categories=false' do
    get '/purchases', params: { include_products: true, include_categories: false }, headers: headers
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    prod = json['data'].first['products'].first
    expect(prod['categories']).to be_nil
  end

  it 'includes products and categories by default' do
    get '/purchases', headers: headers
    json = JSON.parse(response.body)
    prod = json['data'].first['products'].first
    expect(prod['categories']).to be_an(Array)
    expect(prod['categories'].first['name']).to eq('Cat A')
  end
end
