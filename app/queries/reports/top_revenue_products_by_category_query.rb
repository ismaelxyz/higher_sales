# frozen_string_literal: true

module Reports
  class TopRevenueProductsByCategoryQuery
    CACHE_TTL = 5.minutes

    class << self
      def call(limit: 3, cache: true)
        lim = Integer(limit).clamp(1, 100)
        if cache
          Rails.cache.fetch(cache_key(lim), expires_in: CACHE_TTL) { run(lim) }
        else
          run(lim)
        end
      end

      def cache_key(limit)
        "reports:top_revenue_products_by_category:v1:limit=#{Integer(limit)}"
      end

      private

      def run(limit)
        sql = sql_for(limit)
        result = ActiveRecord::Base.connection.exec_query(sql)
        result.to_a.map do |row|
          {
            category_id: row["category_id"].to_i,
            category_name: row["category_name"],
            products: JSON.parse(row["products"]).map do |p|
              { id: p["id"].to_i, name: p["name"], total_revenue: p["total_revenue"].to_f }
            end
          }
        end
      end

      def sql_for(limit)
        lim = Integer(limit)
        <<~SQL.squish
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
          WHERE rn <= #{lim}
          GROUP BY category_id, category_name
          ORDER BY category_id ASC
        SQL
      end
    end
  end
end
