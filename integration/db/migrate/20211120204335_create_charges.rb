# frozen_string_literal: true

class CreateCharges < ActiveRecord::Migration[6.1]
  def change
    create_table :charges do |t|
      t.belongs_to :customer, null: false, foreign_key: true
      t.integer    :amount_cents, null: false
      t.string     :currency, null: false
      t.timestamps
    end
  end
end
