class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases do |t|
      t.references :clients, null: false, foreign_key: true
      t.decimal :total_price

      t.timestamps
    end
  end
end
