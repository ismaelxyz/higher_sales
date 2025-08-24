class AddIndexOnPurchasesCreatedAt < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :purchases, :created_at, algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :purchases, column: :created_at, if_exists: true
  end
end
