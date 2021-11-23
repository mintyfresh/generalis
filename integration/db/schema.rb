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

ActiveRecord::Schema.define(version: 2021_11_20_205654) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "charges", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_charges_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ledger_accounts", force: :cascade do |t|
    t.string "type", null: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "name", null: false
    t.integer "coefficient", null: false
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["name"], name: "index_ledger_accounts_on_name", unique: true, where: "(owner_id IS NULL)"
    t.index ["owner_type", "owner_id", "name"], name: "index_ledger_accounts_on_owner_type_and_owner_id_and_name", unique: true
    t.index ["owner_type", "owner_id"], name: "index_ledger_accounts_on_owner"
    t.check_constraint "coefficient = ANY (ARRAY['-1'::integer, (+ 1)])"
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.string "type", null: false
    t.bigint "account_id", null: false
    t.bigint "transaction_id", null: false
    t.uuid "pair_id"
    t.string "currency", null: false
    t.integer "amount_cents", null: false
    t.integer "balance_after_cents", null: false
    t.integer "coefficient", null: false
    t.jsonb "metadata"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["account_id", "currency", "id"], name: "index_ledger_entries_on_account_id_and_currency_and_id", order: { id: :desc }
    t.index ["account_id"], name: "index_ledger_entries_on_account_id"
    t.index ["transaction_id", "pair_id"], name: "index_ledger_entries_on_transaction_id_and_pair_id"
    t.index ["transaction_id"], name: "index_ledger_entries_on_transaction_id"
    t.check_constraint "amount_cents >= 0"
    t.check_constraint "coefficient = ANY (ARRAY['-1'::integer, (+ 1)])"
  end

  create_table "ledger_links", force: :cascade do |t|
    t.bigint "transaction_id", null: false
    t.string "linkable_type", null: false
    t.bigint "linkable_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["linkable_type", "linkable_id"], name: "index_ledger_links_on_linkable"
    t.index ["transaction_id", "name"], name: "index_ledger_links_on_transaction_id_and_name"
    t.index ["transaction_id"], name: "index_ledger_links_on_transaction_id"
  end

  create_table "ledger_transactions", force: :cascade do |t|
    t.string "type"
    t.string "transaction_id", null: false
    t.string "description"
    t.jsonb "metadata"
    t.datetime "occurred_at", default: -> { "now()" }, null: false
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["transaction_id"], name: "index_ledger_transactions_on_transaction_id", unique: true
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "provider_id", null: false
    t.integer "order_amount_cents", null: false
    t.integer "delivery_fee_cents", null: false
    t.integer "platform_fee_cents", null: false
    t.integer "total_cents", null: false
    t.string "currency", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["provider_id"], name: "index_orders_on_provider_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "provider_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provider_id"], name: "index_payments_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "charges", "customers"
  add_foreign_key "ledger_entries", "ledger_accounts", column: "account_id"
  add_foreign_key "ledger_entries", "ledger_transactions", column: "transaction_id"
  add_foreign_key "ledger_links", "ledger_transactions", column: "transaction_id", on_delete: :cascade
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "providers"
  add_foreign_key "payments", "providers"
end
