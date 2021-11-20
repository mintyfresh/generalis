# frozen_string_literal: true

class CreateLedgerOperations < ActiveRecord::Migration[6.1]
  def change
    create_table :ledger_operations do |t|
      t.string     :type, null: false
      t.belongs_to :account, null: false, foreign_key: { to_table: :ledger_accounts }
      t.belongs_to :entry, null: false, foreign_key: { to_table: :ledger_entries }
      t.string     :label, null: true
      t.string     :currency, null: false
      t.integer    :amount_cents, null: false
      t.integer    :balance_after_cents, null: false
      t.integer    :coefficient, null: false
      t.column     :metadata, :jsonb
      t.timestamps default: -> { 'NOW()' }

      t.check_constraint 'amount_cents >= 0'
      t.check_constraint 'coefficient IN (-1, +1)'

      t.index %i[entry_id label], unique: true
      # Index for efficiently selecting the latest balance on the account.
      t.index %i[account_id currency id], order: { id: :desc }
    end
  end
end
