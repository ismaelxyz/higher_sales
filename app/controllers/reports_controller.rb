class ReportsController < ApplicationController
  # GET /reports/top-products-by-category?limit=3
  def top_products_by_category
    limit = params.fetch(:limit, 3).to_i
    rows = ProductsSold
             .joins(product: { products_categories: :category })
             .group("categories.id", "categories.name", "products.id", "products.name")
             .select("categories.id AS category_id, categories.name AS category_name, products.id AS product_id, products.name AS product_name, COUNT(products_solds.id) AS total_sold")
             .order("categories.id ASC, total_sold DESC")

    grouped = rows.group_by(&:category_id).map do |category_id, records|
      {
        category_id: category_id,
        category_name: records.first.category_name,
        products: records.first(limit).map { |r| { id: r.product_id, name: r.product_name, total_sold: r.total_sold.to_i } }
      }
    end

    render json: grouped, status: :ok
  end

  # GET /reports/top-revenue-products-by-category?limit=3
  # Returns, para cada categoría, los N (default 3) productos con mayor recaudación (SUM precio en products_solds)
  def top_revenue_products_by_category
    limit = params.fetch(:limit, 3).to_i
    rows = ProductsSold
             .joins(product: { products_categories: :category })
             .group("categories.id", "categories.name", "products.id", "products.name")
             .select("categories.id AS category_id, categories.name AS category_name, products.id AS product_id, products.name AS product_name, COALESCE(SUM(products_solds.price),0) AS total_revenue")
             .order("categories.id ASC, total_revenue DESC")

    grouped = rows.group_by(&:category_id).map do |category_id, records|
      {
        category_id: category_id,
        category_name: records.first.category_name,
        products: records.first(limit).map do |r|
          { id: r.product_id, name: r.product_name, total_revenue: r.total_revenue.to_f }
        end
      }
    end

    render json: grouped, status: :ok
  end
end
