FactoryBot.define do
  factory :products_sold do
    association :purchase
    association :product
    price { product.price }
  end
end
