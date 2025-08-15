require 'rails_helper'


RSpec.describe ProductMailer, type: :mailer do
  feature 'ProductMailer' do
    scenario 'sends email to product creator and CCs other admins on first purchase' do
      creator = create(:admin)
      other_admins = create_list(:admin, 2)
      product = create(:product, created_by_admin: creator)
      client = create(:client)

      expect {
        create(:purchase, product: product, client: client)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(creator.email)
      expect(email.cc).to match_array(other_admins.map(&:email))
      expect(email.subject).to include("First purchase of #{product.name}")
    end
  end
end
