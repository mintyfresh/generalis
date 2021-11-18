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
  class Operation < ActiveRecord::Base
    CREDIT = -1
    DEBIT  = +1

    attr_readonly :type, :account_id, :entry_id, :currency, :amount_cents, :coefficient

    belongs_to :account, inverse_of: :operations
    belongs_to :entry, inverse_of: :operations

    validates :currency, presence: true
    validates :coefficient, inclusion: { in: [CREDIT, DEBIT] }

    with_options with_model_currency: :currency do
      monetize :amount_cents, numericality: { greater_than: 0 }
      monetize :balance_after_cents, allow_nil: true
    end

    before_create do
      self.balance_after = account.balance(currency) + net_amount
    end

    scope :at_or_before, -> (time) { joins(:entry).merge(Entry.at_or_before(time)) }

    # @param value [Integer]
    # @return [void]
    def self.coefficient=(coefficient)
      after_initialize(if: :new_record?) { self.coefficient = coefficient }
    end

    # @return [Boolean]
    def credit?
      coefficient == CREDIT
    end

    # @return [Boolean]
    def debit?
      coefficient == DEBIT
    end

    # The net change in balance that is applied to the account.
    #
    # @return [Money]
    def net_amount
      amount * coefficient * account.coefficient
    end
  end
end
