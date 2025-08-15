class ProductsSold < ApplicationRecord
  belongs_to :purchase, class_name: "Purchase", foreign_key: "purchases_id"
  belongs_to :product, class_name: "Product", foreign_key: "products_id"

  after_create :notify_first_purchase

  private

  def notify_first_purchase
    # Only trigger when this is the client's first purchase and this is the first product on that purchase
    return unless purchase.client.purchases.count == 1
    return unless purchase.products_solds.count == 1

    ProductMailer.first_purchase_notification(product, purchase.client).deliver_now
  end
end
