class Admin < ApplicationRecord
    validates :name, :email, :password, presence: true
    validates :email, uniqueness: true

    has_many :products, foreign_key: :created_by_admin_id
end
