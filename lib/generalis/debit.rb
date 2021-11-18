# frozen_string_literal: true

# == Schema Information
#
# Table name: ledger_operations
#
#  id                  :bigint           not null, primary key
#  type                :string           not null
#  account_id          :bigint           not null
#  entry_id            :bigint           not null
#  currency            :string           not null
#  amount_cents        :integer          not null
#  balance_after_cents :integer          not null
#  coefficient         :integer          not null
#  metadata            :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_ledger_operations_on_account_id                      (account_id)
#  index_ledger_operations_on_account_id_and_currency_and_id  (account_id,currency,id DESC)
#  index_ledger_operations_on_entry_id                        (entry_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => ledger_accounts.id)
#  fk_rails_...  (entry_id => ledger_entries.id)
#
module Generalis
  class Debit < Operation
    self.coefficient = DEBIT
  end
end
