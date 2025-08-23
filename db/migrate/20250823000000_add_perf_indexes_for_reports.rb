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
