FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    description { 'Category description' }
    association :created_by_admin, factory: :admin
  end
end
