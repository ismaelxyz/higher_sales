class ProductsSold < ApplicationRecord
  belongs_to :purchase, class_name: "Purchase", foreign_key: "purchases_id"
  belongs_to :product, class_name: "Product", foreign_key: "products_id"
end
