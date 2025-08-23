class FirstPurchaseNotificationJob < ApplicationJob
  queue_as :mailers


  # Executes the first purchase notification job for a given ProductsSold record.
  #
  # This method performs the following steps:
  # 1. Finds the ProductsSold record by its ID.
  # 2. Returns early if the record is not found.
  # 3. Retrieves the associated purchase and client.
  # 4. Checks if this is the client's first purchase and if the purchase contains only one product sold.
  # 5. Within a new database transaction, attempts to create a ClientFirstPurchaseNotification record.
  #    - If a uniqueness or validation error occurs, the method returns without raising an exception.
  # 6. Sends a first purchase notification email to the client for the purchased product.
  #
  # @param products_sold_id [Integer] The ID of the ProductsSold record to process.
  # @return [void]
  def perform(products_sold_id)
    ps = ProductsSold.find_by(id: products_sold_id)
    return unless ps

    purchase = ps.purchase
    client = purchase.client


    return unless client.purchases.where("purchases.created_at <= ?", purchase.created_at).count == 1
    return unless purchase.products_solds.count == 1

    begin
      ApplicationRecord.transaction(requires_new: true) do
        ClientFirstPurchaseNotification.create!(client: client, purchase: purchase, products_sold: ps)
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      return
    end

    ProductMailer.first_purchase_notification(ps.product, client).deliver_now
  end
end
