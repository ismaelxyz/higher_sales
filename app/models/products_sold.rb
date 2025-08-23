class ProductsSold < ApplicationRecord
  belongs_to :purchase, class_name: "Purchase", foreign_key: "purchases_id"
  belongs_to :product, class_name: "Product", foreign_key: "products_id"

  # Run after commit to avoid sending emails for rolled-back records
  after_commit :notify_first_purchase, on: :create

  private


  # Schedules a background job to notify about the first purchase of this product.
  # The notification is delayed by 2 seconds.
  #
  # @return [void]
  def notify_first_purchase
    FirstPurchaseNotificationJob.set(wait: 2.seconds).perform_later(id)
  end
end
