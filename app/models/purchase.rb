class Purchase < ApplicationRecord
  belongs_to :client, class_name: "Client", foreign_key: "clients_id"

  has_many :products_solds, class_name: "ProductsSold", foreign_key: "purchases_id", dependent: :destroy
  has_many :products, through: :products_solds, source: :product
end
