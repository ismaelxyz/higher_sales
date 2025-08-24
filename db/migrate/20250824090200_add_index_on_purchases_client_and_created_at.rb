class AddIndexOnPurchasesClientAndCreatedAt < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :purchases, [ :clients_id, :created_at ], algorithm: :concurrently, if_not_exists: true, name: "index_purchases_on_clients_id_and_created_at"
  end

  def down
    remove_index :purchases, name: "index_purchases_on_clients_id_and_created_at", if_exists: true
  end
end
