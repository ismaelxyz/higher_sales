# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_15_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_change_logs", force: :cascade do |t|
    t.bigint "admin_id", null: false
    t.string "table_name"
    t.string "target_type"
    t.text "old_value"
    t.text "new_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_change_logs_on_admin_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_admin_id", null: false
    t.index ["created_by_admin_id"], name: "index_categories_on_created_by_admin_id"
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.text "name"
    t.text "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.string "path"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_images_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.bigint "created_by_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_admin_id"], name: "index_products_on_created_by_admin_id"
    t.index ["name"], name: "index_products_on_name", unique: true
  end

  create_table "products_categories", force: :cascade do |t|
    t.bigint "categories_id", null: false
    t.bigint "products_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categories_id"], name: "index_products_categories_on_categories_id"
    t.index ["products_id"], name: "index_products_categories_on_products_id"
  end

  create_table "products_solds", force: :cascade do |t|
    t.bigint "purchases_id", null: false
    t.bigint "products_id", null: false
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["products_id"], name: "index_products_solds_on_products_id"
    t.index ["purchases_id"], name: "index_products_solds_on_purchases_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "clients_id", null: false
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clients_id"], name: "index_purchases_on_clients_id"
  end

  add_foreign_key "admin_change_logs", "admins"
  add_foreign_key "categories", "admins", column: "created_by_admin_id"
  add_foreign_key "images", "products"
  add_foreign_key "products", "admins", column: "created_by_admin_id"
  add_foreign_key "products_categories", "categories", column: "categories_id"
  add_foreign_key "products_categories", "products", column: "products_id"
  add_foreign_key "products_solds", "products", column: "products_id"
  add_foreign_key "products_solds", "purchases", column: "purchases_id"
  add_foreign_key "purchases", "clients", column: "clients_id"
end
