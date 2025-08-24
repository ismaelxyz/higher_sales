# Represents a product in the system.
class Product < ApplicationRecord
  belongs_to :created_by_admin, class_name: "Admin"
  has_many :images

  has_many :products_categories, class_name: "ProductsCategory", foreign_key: "products_id"
  has_many :categories, through: :products_categories
end
