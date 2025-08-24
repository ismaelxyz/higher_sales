# Controller for generating various sales reports.
class ReportsController < ApplicationController
  # GET /reports/top-products-by-category?limit=3
  def top_products_by_category
  limit = params.fetch(:limit, 3)
  render json: Reports::TopProductsByCategoryQuery.call(limit: limit), status: :ok
  end

  # GET /reports/top-revenue-products-by-category?limit=3
  # Returns, para cada categoría, los N (default 3) productos con mayor recaudación (SUM precio en products_solds)
  def top_revenue_products_by_category
  limit = params.fetch(:limit, 3)
  render json: Reports::TopRevenueProductsByCategoryQuery.call(limit: limit), status: :ok
  end
end
