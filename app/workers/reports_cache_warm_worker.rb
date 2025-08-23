# frozen_string_literal: true

class ReportsCacheWarmWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 2

  DEFAULT_LIMITS = [ 3 ].freeze

  def perform
    DEFAULT_LIMITS.each do |limit|
      warm_top_products_by_category(limit)
      warm_top_revenue_products_by_category(limit)
    end
  end

  private

  def warm_top_products_by_category(limit)
    sql = <<~SQL.squish
      WITH aggregated AS (
        SELECT c.id AS category_id,
               c.name AS category_name,
               p.id AS product_id,
               p.name AS product_name,
               COUNT(ps.id) AS total_sold
        FROM products_solds ps
        JOIN products p ON p.id = ps.products_id
        JOIN products_categories pc ON pc.products_id = p.id
        JOIN categories c ON c.id = pc.categories_id
        GROUP BY c.id, c.name, p.id, p.name
      ), ranked AS (
        SELECT *, ROW_NUMBER() OVER (
          PARTITION BY category_id
          ORDER BY total_sold DESC, product_id ASC
        ) AS rn
        FROM aggregated
      )
      SELECT category_id,
             category_name,
             json_agg(
               json_build_object(
                 'id', product_id,
                 'name', product_name,
                 'total_sold', total_sold
               )
               ORDER BY total_sold DESC, product_id ASC
             ) AS products
      FROM ranked
      WHERE rn <= #{Integer(limit)}
      GROUP BY category_id, category_name
      ORDER BY category_id ASC
    SQL

    Rails.cache.fetch("reports:top_products_by_category:v1:limit=#{limit}", expires_in: 5.minutes) do
      ActiveRecord::Base.connection.exec_query(sql).to_a
    end
  end

  def warm_top_revenue_products_by_category(limit)
    sql = <<~SQL.squish
      WITH aggregated AS (
        SELECT c.id AS category_id,
               c.name AS category_name,
               p.id AS product_id,
               p.name AS product_name,
               COALESCE(SUM(ps.price), 0) AS total_revenue
        FROM products_solds ps
        JOIN products p ON p.id = ps.products_id
        JOIN products_categories pc ON pc.products_id = p.id
        JOIN categories c ON c.id = pc.categories_id
        GROUP BY c.id, c.name, p.id, p.name
      ), ranked AS (
        SELECT *, ROW_NUMBER() OVER (
          PARTITION BY category_id
          ORDER BY total_revenue DESC, product_id ASC
        ) AS rn
        FROM aggregated
      )
      SELECT category_id,
             category_name,
             json_agg(
               json_build_object(
                 'id', product_id,
                 'name', product_name,
                 'total_revenue', total_revenue
               )
               ORDER BY total_revenue DESC, product_id ASC
             ) AS products
      FROM ranked
      WHERE rn <= #{Integer(limit)}
      GROUP BY category_id, category_name
      ORDER BY category_id ASC
    SQL

    Rails.cache.fetch("reports:top_revenue_products_by_category:v1:limit=#{limit}", expires_in: 5.minutes) do
      ActiveRecord::Base.connection.exec_query(sql).to_a
    end
  end
end
