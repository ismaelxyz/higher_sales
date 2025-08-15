require 'rails_helper'

RSpec.describe 'DailyPurchasesReport', type: :mailer do
  describe 'daily report mail' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it 'sends report with aggregated product sales for previous day' do
      Admin.delete_all
      create_list(:admin, 3)

      # Fix current date to ensure determinism
      travel_to Time.zone.parse('2025-08-14 09:00:00 UTC') do
        date_yesterday = Date.yesterday
        product_a = create(:product, name: 'Alpha')
        product_b = create(:product, name: 'Beta')
        client = create(:client)

        # Create purchases (initially timestamped "now") then backdate them to yesterday
        purchase1 = create(:purchase, client: client, products: [ product_a, product_b ])
        purchase2 = create(:purchase, client: client, product: product_a)

        # Backdate their products_solds entries to yesterday at different times
        ts1 = date_yesterday.to_time.change(hour: 10)
        ts2 = date_yesterday.to_time.change(hour: 15)
        purchase1.update_columns(created_at: ts1, updated_at: ts1)
        purchase2.update_columns(created_at: ts2, updated_at: ts2)
        purchase1.products_solds.update_all(created_at: ts1, updated_at: ts1)
        purchase2.products_solds.update_all(created_at: ts2, updated_at: ts2)

        # Create a purchase today that must be excluded
        create(:purchase, client: client, product: product_b)

        expect {
          DailyPurchasesReportWorker.perform_async(date_yesterday.to_s)
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        email = ActionMailer::Base.deliveries.last
        expected_recipients = Admin.pluck(:email)
        expect(email.to).to match_array(expected_recipients)
        expect(email.subject).to include(date_yesterday.to_s)
        body = email.body.decoded
        expect(body).to include('Alpha | 2')
        expect(body).to include('Beta | 1')
      end
    end

    it 'states no purchases when none occurred' do
      Admin.delete_all
      create_list(:admin, 2)
      date_yesterday = Date.new(2025, 8, 13)

      expect {
        DailyPurchasesReportWorker.perform_async(date_yesterday.to_s)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      email = ActionMailer::Base.deliveries.last
      expect(email.body.decoded).to include('No purchases were made yesterday')
    end
  end
end
