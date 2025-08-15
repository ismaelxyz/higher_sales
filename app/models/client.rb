class Client < ApplicationRecord
  has_many :purchases, class_name: "Purchase", foreign_key: "clients_id", inverse_of: :client, dependent: :destroy
end
