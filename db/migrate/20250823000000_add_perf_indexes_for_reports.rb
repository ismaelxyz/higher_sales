# Migration: AddPerfIndexesForReports
#
# This migration adds performance indexes to improve query efficiency for reporting.
#
# - Adds indexes to the `products_solds` table on `products_id` and `purchases_id` columns.
# - Adds indexes to the `products_categories` join table on `products_id`, `categories_id`, and a composite index on `[categories_id, products_id]`.
# - All indexes are created concurrently and only if they do not already exist.
# - Disables DDL transaction to allow concurrent index creation.
#
class AddPerfIndexesForReports < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # ProductsSold large table access paths
    add_index :products_solds, :products_id, algorithm: :concurrently, if_not_exists: true
    add_index :products_solds, :purchases_id, algorithm: :concurrently, if_not_exists: true

    # Join tables
    add_index :products_categories, :products_id, algorithm: :concurrently, if_not_exists: true
    add_index :products_categories, :categories_id, algorithm: :concurrently, if_not_exists: true
    add_index :products_categories, [ :categories_id, :products_id ], algorithm: :concurrently, if_not_exists: true
  end
end
