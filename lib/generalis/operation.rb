# frozen_string_literal: true

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
