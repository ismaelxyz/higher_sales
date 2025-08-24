require 'rails_helper'

RSpec.describe FirstPurchaseNotificationJob, type: :job do
  it 'sends only one email and creates one marker when executed concurrently for the same products_sold' do
    ActionMailer::Base.deliveries.clear

    creator = create(:admin)
    create(:admin)

    product = create(:product, created_by_admin: creator)
    client  = create(:client)

    purchase = create(:purchase, product: product, client: client)
    ps = purchase.products_solds.first

    # Run the same job twice "at the same time" to simulate a duplicate/concurrent execution
    perform_enqueued_jobs do
      t1 = Thread.new { FirstPurchaseNotificationJob.new.perform(ps.id) }
      t2 = Thread.new { FirstPurchaseNotificationJob.new.perform(ps.id) }
      [ t1, t2 ].each(&:join)
    end

    expect(ClientFirstPurchaseNotification.where(client: client).count).to eq(1)

    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
end
