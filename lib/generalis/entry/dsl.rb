# frozen_string_literal: true

module Generalis
  class Entry < ActiveRecord::Base
    module DSL
    protected

      def transaction_id(&block)
        after_initialize(if: :new_record?) do
          self.transaction_id = instance_exec(&block)
        end
      end

      def description(&block)
        after_initialize(if: :new_record?) do
          self.description = instance_exec(&block)
        end
      end

      def metadata(&block)
        after_initialize(if: :new_record?) do
          self.metadata = instance_exec(&block)
        end
      end

      def occurred_at(&block)
        after_initialize(if: :new_record?) do
          self.occurred_at = instance_exec(&block)
        end
      end

      def credit(&block)
        after_initialize(if: :new_record?) do
          credit = Credit.new
          instance_exec(credit, &block)

          operations << credit
        end
      end

      def debit(&block)
        after_initialize(if: :new_record?) do
          debit = Debit.new
          instance_exec(debit, &block)

          operations << debit
        end
      end
    end
  end
end
