class AddIndexOnProductsSoldsCreatedAt < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :products_solds, :created_at, algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :products_solds, column: :created_at, if_exists: true
  end
end
