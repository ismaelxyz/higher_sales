FactoryBot.define do
  factory :client do
    name { "John Doe" }
    sequence(:email) { |n| "client#{n}@example.com" }
  end
end
