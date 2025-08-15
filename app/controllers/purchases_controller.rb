class PurchasesController < ApplicationController
  # GET /purchases
  #  Optional Parameters:
  # from: start date/time (YYYY-MM-DD or ISO8601)
  # to: end date/time (YYYY-MM-DD or ISO8601)
  # category_id: filters purchases that include at least one product from the given category
  # client_id: filters purchases by client
  # admin_id: filters purchases that include products created by the specified admin (any product in the purchase)
  def index
    purchases = filtered_purchases.includes(:client, products_solds: { product: { products_categories: :category } })
    render json: purchases.map { |p| serialize_purchase(p) }
  end

  # GET /purchases/counts?granularity=hour|day|week|year plus same filters as index
  # Returns JSON: { granularity: 'day', data: { '2025-08-15': 12, ... } }
  def counts
    granularity = params[:granularity].to_s.downcase
    return render json: { error: "granularity param required (hour|day|week|year)" }, status: :unprocessable_content if granularity.blank?

    valid = %w[hour day week year]
    return render json: { error: "invalid granularity" }, status: :unprocessable_content unless valid.include?(granularity)

    scope = filtered_purchases

    date_trunc_part = granularity
    time_expr = Arel.sql("DATE_TRUNC('#{date_trunc_part}', purchases.created_at)")
    counts_hash = scope.group(time_expr).order(time_expr).count

    formatted = counts_hash.each_with_object({}) do |(bucket_time, count), acc|
      acc[format_bucket(bucket_time, granularity)] = count
    end

    render json: { granularity: granularity, data: formatted }
  end

  private

  # Builds a filtered Purchase scope based on accepted params
  def filtered_purchases
    purchases = Purchase.all

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

    purchases
  end

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

  def format_bucket(time, granularity)
    case granularity
    when "hour"
      time.strftime("%Y-%m-%d %H:00")
    when "day"
      time.strftime("%Y-%m-%d")
    when "week"
      # ISO week: YYYY-Www
      time.strftime("%G-W%V")
    when "year"
      time.strftime("%Y")
    else
      time.to_s
    end
  end
end
