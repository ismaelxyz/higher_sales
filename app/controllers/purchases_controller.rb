class PurchasesController < ApplicationController
  # GET /purchases
  #  Optional Parameters:
  # from: start date/time (YYYY-MM-DD or ISO8601)
  # to: end date/time (YYYY-MM-DD or ISO8601)
  # category_id: filters purchases that include at least one product from the given category
  # client_id: filters purchases by client
  # admin_id: filters purchases that include products created by the specified admin (any product in the purchase)
  def index
    purchases = Purchase.includes(:client, products_solds: { product: { products_categories: :category } })

    # Date range filtering (uses purchases created_at)
    from_param = params[:from]
    to_param = params[:to]
    if from_param.present?
      from_time = parse_date_time(from_param)&.beginning_of_day
      purchases = purchases.where("purchases.created_at >= ?", from_time) if from_time
    end
    if to_param.present?
      to_time = parse_date_time(to_param)&.end_of_day
      purchases = purchases.where("purchases.created_at <= ?", to_time) if to_time
    end

    if params[:client_id].present?
      purchases = purchases.where(clients_id: params[:client_id])
    end

    if params[:category_id].present?
      purchases = purchases.joins(products_solds: { product: :products_categories })
                           .where(products_categories: { categories_id: params[:category_id] })
                           .distinct
    end

    if params[:admin_id].present?
      purchases = purchases.joins(products_solds: { product: :created_by_admin })
                           .where(products: { created_by_admin_id: params[:admin_id] })
                           .distinct
    end

    render json: purchases.map { |p| serialize_purchase(p) }
  end

  private

  def serialize_purchase(purchase)
    {
      id: purchase.id,
      created_at: purchase.created_at,
      total_price: purchase.total_price.to_f,
      client: { id: purchase.client.id, name: purchase.client.name },
      products: purchase.products_solds.map do |ps|
        prod = ps.product
        {
          id: prod.id,
          name: prod.name,
          price: ps.price.to_f,
          admin_id: prod.created_by_admin_id,
          categories: prod.categories.map { |c| { id: c.id, name: c.name } }
        }
      end
    }
  end

  def parse_date_time(value)
    Time.zone.parse(value)
  rescue ArgumentError, TypeError
    nil
  end
end
