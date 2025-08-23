class ClientFirstPurchaseNotification < ApplicationRecord
  belongs_to :client
  belongs_to :purchase, optional: true
  belongs_to :products_sold, class_name: "ProductsSold", optional: true
end
