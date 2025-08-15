class Category < ApplicationRecord
    belongs_to :created_by_admin, class_name: "Admin"
    has_many :products_categories, class_name: "ProductsCategory", foreign_key: "categories_id", dependent: :destroy
    has_many :products, through: :products_categories

    validates :name, :description, presence: true
    validates :name, uniqueness: true, length: { maximum: 255 }
end
