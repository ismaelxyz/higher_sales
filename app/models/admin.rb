class Admin < ApplicationRecord
    has_secure_password

    validates :name, :email, presence: true
    validates :email, uniqueness: true

    has_many :products, foreign_key: :created_by_admin_id
end
