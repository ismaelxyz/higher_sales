require 'rails_helper'

RSpec.describe 'Purchases counts', type: :request do
  let!(:admin) { create(:admin) }
  let!(:token) { JsonWebToken.jwt_encode({ admin_id: admin.id }) }
  let!(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let!(:category) { create(:category) }
  let!(:product1) { create(:product, categories: [ category ]) }
  let!(:product2) { create(:product, categories: [ category ]) }
  let!(:client) { create(:client) }

  before do
    # Create purchases at different hours/days
    travel_to Time.zone.parse('2025-08-14 10:15') do
      create(:purchase, client: client, products: [ product1 ])
      create(:purchase, client: client, products: [ product2 ])
    end
    travel_to Time.zone.parse('2025-08-14 11:05') do
      create(:purchase, client: client, products: [ product1 ])
    end
    travel_to Time.zone.parse('2025-08-15 09:30') do
      create(:purchase, client: client, products: [ product2 ])
    end
  end

  it 'requires auth' do
    get '/purchases/counts'
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns counts by hour' do
    get '/purchases/counts', params: { granularity: 'hour' }, headers: headers
    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body)['data']
    expect(data['2025-08-14 10:00']).to eq(2)
    expect(data['2025-08-14 11:00']).to eq(1)
    expect(data['2025-08-15 09:00']).to eq(1)
  end

  it 'returns counts by day' do
    get '/purchases/counts', params: { granularity: 'day' }, headers: headers
    data = JSON.parse(response.body)['data']
    expect(data['2025-08-14']).to eq(3)
    expect(data['2025-08-15']).to eq(1)
  end

  it 'filters with category_id' do
    get '/purchases/counts', params: { granularity: 'day', category_id: category.id }, headers: headers
    data = JSON.parse(response.body)['data']
    expect(data.values.sum).to eq(4)
  end

  it 'returns error on invalid granularity' do
    get '/purchases/counts', params: { granularity: 'minute' }, headers: headers
    expect(response).to have_http_status(:unprocessable_content)
  end
end
