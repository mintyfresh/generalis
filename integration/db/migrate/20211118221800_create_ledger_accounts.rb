# frozen_string_literal: true

class CreateLedgerAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :ledger_accounts do |t|
      t.string     :type, null: false
      t.belongs_to :owner, null: true, polymorphic: true
      t.string     :name, null: false
      t.integer    :coefficient, null: false
      t.timestamps default: -> { 'NOW()' }

      t.check_constraint 'coefficient IN (-1, +1)'

      t.index %i[owner_type owner_id name], unique: true
      t.index :name, unique: true, where: 'owner_id IS NULL'
    end
  end
end
