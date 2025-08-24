# Represents an image associated with a product.
class Image < ApplicationRecord
  belongs_to :product
end
