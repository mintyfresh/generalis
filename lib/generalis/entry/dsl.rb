# frozen_string_literal: true

module Generalis
  class Entry < ActiveRecord::Base
    module DSL
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

      # @param label [Symbol, String, nil]
      # @return [void]
      def credit(label = nil, &block)
        before_validation(if: :new_record?) do
          credit = Credit.new(label: label)
          instance_exec(credit, &block)

          operations << credit
        end
      end

      # @param label [Symbol, String, nil]
      # @return [void]
      def debit(label = nil, &block)
        before_validation(if: :new_record?) do
          debit = Debit.new(label: label)
          instance_exec(debit, &block)

          operations << debit
        end
      end
    end
  end
end
