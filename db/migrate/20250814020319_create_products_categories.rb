class CreateProductsCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :products_categories do |t|
      t.references :categories, null: false, foreign_key: true
      t.references :products, null: false, foreign_key: true

      t.timestamps
    end
  end
end
