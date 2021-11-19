# frozen_string_literal: true

module Generalis
  module RSpec
    module ResolveAccountHelper
      # @param location [Symbol, String, Generalis::Account]
      # @param owner [ActiveRecord::Base, nil]
      # @return [Generalis::Account]
      def resolve_account(locator, owner:)
        case locator
        when Generalis::Account
          locator
        when String, Symbol
          Generalis::Account.lookup(locator, owner: owner)
        else
          raise ArgumentError, "Expected a Generalis::Account, String, or Symbol, got #{account.inspect}"
        end
      end
    end
  end
end
