# frozen_string_literal: true

module Generalis
  class Entry < ActiveRecord::Base
    CREDIT = -1
    DEBIT  = +1

    attr_readonly :type, :account_id, :transaction_id, :pair_id, :currency, :amount_cents, :coefficient

    belongs_to :account, inverse_of: :entries
    belongs_to :ledger_transaction, class_name: 'Transaction', foreign_key: :transaction_id, inverse_of: :entries

    validates :currency, presence: true
    validates :coefficient, inclusion: { in: [CREDIT, DEBIT] }

    with_options with_model_currency: :currency do
      monetize :amount_cents, numericality: { greater_than_or_equal_to: 0 }
      monetize :balance_after_cents, allow_nil: true
    end

    before_create do
      self.balance_after = account.balance(currency) + net_amount
    end

    scope :credit, -> { where(coefficient: CREDIT) }
    scope :debit,  -> { where(coefficient: DEBIT)  }

    scope :before, -> (entry) { where(arel_table[:id].lt(entry.id)) }
    scope :after,  -> (entry) { where(arel_table[:id].gt(entry.id)) }

    scope :at_or_before, -> (time) { joins(:transaction).merge(Transaction.at_or_before(time)) }

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

    # @return [Boolean]
    def no_op?
      amount.zero?
    end

    # @return [Entry, nil]
    def opposite
      ledger_transaction.entries.find_by(pair_id: pair_id, coefficient: -coefficient)
    end
  end
end
