FactoryBot.define do
  factory :product do
    name { "Sample Product" }
    description { "This is a sample product." }
    price { 19.99 }
    association :created_by_admin, factory: :admin

    transient do
      categories { [] }
    end

    after(:create) do |product, evaluator|
      Array(evaluator.categories).each do |cat|
        ProductsCategory.create!(product: product, category: cat)
      end
    end
  end
end
