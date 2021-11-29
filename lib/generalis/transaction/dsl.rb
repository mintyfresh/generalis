# frozen_string_literal: true

require_relative 'double_entry'
require_relative 'preparation'

module Generalis
  class Transaction < ActiveRecord::Base
    module DSL
      def self.extended(klass)
        super(klass)

        klass.include(Preparation)
        klass.before_validation(:prepare, if: :new_record?)
      end

      def transaction_id(&block)
        prepare_with do
          self.transaction_id = instance_exec(&block)
        end
      end

      def description(&block)
        prepare_with do
          self.description = instance_exec(&block)
        end
      end

      def metadata(&block)
        prepare_with do
          self.metadata = instance_exec(&block)
        end
      end

      def occurred_at(&block)
        prepare_with do
          self.occurred_at = instance_exec(&block)
        end
      end

      # @return [void]
      def credit(&block)
        prepare_with do
          credit = Credit.new
          instance_exec(credit, &block)

          entries << credit
        end
      end

      # @return [void]
      def debit(&block)
        prepare_with do
          debit = Debit.new
          instance_exec(debit, &block)

          entries << debit
        end
      end

      def double_entry(&block)
        prepare_with do
          pair = DoubleEntry.new
          instance_exec(pair, &block)

          entries << pair.entries
        end
      end
    end
  end
end
