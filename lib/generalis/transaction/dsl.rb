# frozen_string_literal: true

module Generalis
  class Transaction < ActiveRecord::Base
    module DSL
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
          if amount.negative?
            # Reverse the debit/credit accounts when supplied a negative amount.
            [Debit.new(account:  credit, amount: -amount, pair_id: pair_id),
             Credit.new(account: debit,  amount: -amount, pair_id: pair_id)]
          else
            [Debit.new(account:  debit,  amount: amount, pair_id: pair_id),
             Credit.new(account: credit, amount: amount, pair_id: pair_id)]
          end
        end

        def pair_id
          @pair_id ||= SecureRandom.uuid
        end
      end

    protected

      def transaction_id(&block)
        before_validation(if: :new_record?) do
          self.transaction_id = instance_exec(&block)
        end
      end

      def description(&block)
        before_validation(if: :new_record?) do
          self.description = instance_exec(&block)
        end
      end

      def metadata(&block)
        before_validation(if: :new_record?) do
          self.metadata = instance_exec(&block)
        end
      end

      def occurred_at(&block)
        before_validation(if: :new_record?) do
          self.occurred_at = instance_exec(&block)
        end
      end

      # @return [void]
      def credit(&block)
        before_validation(if: :new_record?) do
          credit = Credit.new
          instance_exec(credit, &block)

          entries << credit
        end
      end

      # @return [void]
      def debit(&block)
        before_validation(if: :new_record?) do
          debit = Debit.new
          instance_exec(debit, &block)

          entries << debit
        end
      end

      def double_entry(&block)
        before_validation(if: :new_record?) do
          pair = DoubleEntry.new
          instance_exec(pair, &block)

          entries << pair.entries
        end
      end
    end
  end
end
