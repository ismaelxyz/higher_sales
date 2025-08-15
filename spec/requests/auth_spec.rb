require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  describe 'POST /auth/login' do
    let!(:admin) { create(:admin, password: 'secret123', password_confirmation: 'secret123') }

    it 'returns a JWT token with valid credentials' do
      post '/auth/login', params: { email: admin.email, password: 'secret123' }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['token']).to be_present
    end

    it 'fails with invalid credentials' do
      post '/auth/login', params: { email: admin.email, password: 'wrong' }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
