# frozen_string_literal: true

module Generalis
  class Transaction < ActiveRecord::Base
    DoubleEntry = Struct.new(:credit, :debit, :amount_cents, :currency) do
      def amount
        Money.from_cents(amount_cents || 0, currency)
      end

      def amount=(value)
        value = Money.from_amount(value, currency) unless value.is_a?(Money)

        self.amount_cents = value.cents
        self.currency     = value.currency.iso_code
      end

      # @return [Array<Entry>]
      def entries
        credit, debit = self.credit, self.debit

        # Reverse the debit/credit accounts when supplied a negative amount.
        credit, debit = debit, credit if amount.negative?

        [
          # Flip the amount back to positive since we've already swapped accounts.
          Credit.new(account: credit, amount: amount.abs, pair_id: pair_id),
          Debit.new(account:  debit, amount:  amount.abs, pair_id: pair_id)
        ]
      end

      # @return [String]
      def pair_id
        @pair_id ||= SecureRandom.uuid
      end
    end
  end
end
