# frozen_string_literal: true

module Generalis
  module RSpec
    module ResolveAmountHelper
      # @param amount [Money, Numeric]
      # @param currency [String, nil]
      # @return [Money]
      def resolve_amount(amount, currency = nil)
        case amount
        when Money
          amount
        when Numeric
          Money.from_amount(amount, currency)
        else
          raise ArgumentError, "Expected Money or Numeric, got #{amount.inspect}"
        end
      end
    end
  end
end
