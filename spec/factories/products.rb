FactoryBot.define do
  factory :product do
    name { "Sample Product" }
    description { "This is a sample product." }
    price { 19.99 }
    association :created_by_admin, factory: :admin
  end
end
