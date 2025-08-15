require 'rails_helper'

RSpec.describe 'Purchases index', type: :request do
  let!(:admin) { create(:admin) }
  let!(:other_admin) { create(:admin) }
  let!(:cat_a) { create(:category, name: 'Cat A') }
  let!(:cat_b) { create(:category, name: 'Cat B') }
  let!(:product_a1) { create(:product, name: 'A1', created_by_admin: admin, categories: [ cat_a ]) }
  let!(:product_a2) { create(:product, name: 'A2', created_by_admin: admin, categories: [ cat_a, cat_b ]) }
  let!(:product_b1) { create(:product, name: 'B1', created_by_admin: other_admin, categories: [ cat_b ]) }
  let!(:client1) { create(:client) }
  let!(:client2) { create(:client) }

  let!(:purchase1) { create(:purchase, client: client1, products: [ product_a1 ]) } # only cat A, admin
  let!(:purchase2) { create(:purchase, client: client1, products: [ product_a2, product_b1 ]) } # cat A/B, admin + other_admin
  let!(:purchase3) { create(:purchase, client: client2, products: [ product_b1 ]) } # cat B, other_admin

  let(:token) { JsonWebToken.jwt_encode({ admin_id: admin.id }) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }

  it 'requires auth' do
    get '/purchases'
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns all purchases without filters' do
    get '/purchases', headers: auth_headers
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json.size).to eq(3)
  end

  it 'filters by client_id' do
    get '/purchases', params: { client_id: client1.id }, headers: auth_headers
    json = JSON.parse(response.body)
    ids = json.map { |p| p['id'] }
    expect(ids).to contain_exactly(purchase1.id, purchase2.id)
  end

  it 'filters by category_id (cat A)' do
    get '/purchases', params: { category_id: cat_a.id }, headers: auth_headers
    json = JSON.parse(response.body)
    ids = json.map { |p| p['id'] }
    expect(ids).to contain_exactly(purchase1.id, purchase2.id)
  end

  it 'filters by admin_id (admin)' do
    get '/purchases', params: { admin_id: admin.id }, headers: auth_headers
    json = JSON.parse(response.body)
    ids = json.map { |p| p['id'] }
    expect(ids).to contain_exactly(purchase1.id, purchase2.id)
  end

  it 'filters by date range' do
    purchase2.update!(created_at: 2.days.ago)
    get '/purchases', params: { from: 1.day.ago.to_date.to_s }, headers: auth_headers
    json = JSON.parse(response.body)
    ids = json.map { |p| p['id'] }
    expect(ids).not_to include(purchase2.id)
  end
end
