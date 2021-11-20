# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.belongs_to :provider, null: false, foreign_key: true
      t.integer    :amount_cents, null: false
      t.string     :currency, null: false
      t.timestamps
    end
  end
end
