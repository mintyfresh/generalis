# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.belongs_to :customer, null: false, foreign_key: true
      t.belongs_to :provider, null: false, foreign_key: true
      t.integer    :order_amount_cents, null: false
      t.integer    :delivery_fee_cents, null: false
      t.integer    :platform_fee_cents, null: false
      t.integer    :total_cents, null: false
      t.string     :currency, null: false
      t.timestamps
    end
  end
end
