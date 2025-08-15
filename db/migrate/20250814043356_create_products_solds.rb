class CreateProductsSolds < ActiveRecord::Migration[8.0]
  def change
    create_table :products_solds do |t|
      t.references :purchases, null: false, foreign_key: true
      t.references :products, null: false, foreign_key: true
      t.decimal :price

      t.timestamps
    end
  end
end
