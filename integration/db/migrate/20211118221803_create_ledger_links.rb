# frozen_string_literal: true

class CreateLedgerLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :ledger_links do |t|
      t.belongs_to :transaction, null: false, foreign_key: { on_delete: :cascade, to_table: :ledger_transactions }
      t.belongs_to :linkable, polymorphic: true, null: false
      t.string     :name, null: false
      t.timestamps default: -> { 'NOW()' }

      t.index %i[transaction_id name]
    end
  end
end
