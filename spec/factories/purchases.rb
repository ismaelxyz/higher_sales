FactoryBot.define do
  factory :purchase do
    association :client
    total_price { 0 }

    transient do
      product { nil }
      products { [] }
    end

    after(:create) do |purchase, evaluator|
      # Collect all provided products (single or multiple) and create join records
      items = []
      items << evaluator.product if evaluator.product
      items.concat(Array(evaluator.products))
      items.compact.uniq.each do |prod|
        create(:products_sold, purchase: purchase, product: prod, price: prod.price)
      end

      # Update total price if not explicitly set
      if purchase.total_price.blank? || purchase.total_price.to_f.zero?
        total = purchase.products_solds.sum(:price)
        purchase.update_column(:total_price, total)
      end
    end
  end
end
