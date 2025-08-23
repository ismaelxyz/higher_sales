class CreateClientFirstPurchaseNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :client_first_purchase_notifications do |t|
      t.references :client, null: false, foreign_key: true
      t.references :purchase, null: true, foreign_key: true
      t.references :products_sold, null: true, foreign_key: true
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    add_index :client_first_purchase_notifications, :client_id, unique: true, name: 'index_cfpn_on_client_id_unique'
  end
end
