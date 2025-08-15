class Category < ApplicationRecord
    validates :name, :description, presence: true
    validates :name, uniqueness: true, length: { maximum: 255 }
end
