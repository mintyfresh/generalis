# frozen_string_literal: true

module Generalis
  class Transaction < ActiveRecord::Base
    module Preparation
      extend ActiveSupport::Concern

      class_methods do
        def preparations
          @preparations ||= []
        end

        def prepare_with(&block)
          preparations << block
        end
      end

      included do
        define_model_callbacks :prepare
      end

      # Runs a one-time setup action for the transaction.
      #
      # @return [Boolean]
      def prepare
        return true if prepared?

        @prepared = true

        run_callbacks(:prepare) do
          self.class.preparations.each do |preparation|
            instance_exec(&preparation)
          end
        end

        @prepared
      end

      # @return [Boolean]
      def prepared?
        persisted? || @prepared
      end
    end
  end
end
