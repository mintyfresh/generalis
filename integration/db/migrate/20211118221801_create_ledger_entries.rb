# frozen_string_literal: true

class CreateLedgerEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :ledger_entries do |t|
      t.string     :type
      t.string     :transaction_id, null: false, index: { unique: true }
      t.string     :description
      t.column     :metadata, :jsonb
      t.timestamp  :occurred_at, null: false, default: -> { 'NOW()' }
      t.timestamps default: -> { 'NOW()' }
    end
  end
end
