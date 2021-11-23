# frozen_string_literal: true

module Generalis
  class Account < ActiveRecord::Base
    CREDIT_NORMAL = -1
    DEBIT_NORMAL  = +1

    attr_readonly :type, :coefficient

    belongs_to :owner, optional: true, polymorphic: true

    has_many :operations, dependent: :restrict_with_error, inverse_of: :account
    has_many :ledger_transactions, through: :operations

    validates :name, presence: true
    validates :coefficient, inclusion: { in: [CREDIT_NORMAL, DEBIT_NORMAL] }

    # @param name [Symbol, String]
    # @param owner [ActiveRecord::Base, nil]
    # @return [Account]
    def self.define(name, owner: nil)
      create_or_find_by!(name: name, owner: owner)
    end

    # @param name [Symbol, String]
    # @param owner [ActiveRecord::Base, nil]
    # @return [Account]
    def self.[](name, owner: nil)
      find_by!(name: name, owner: owner)
    end

    # @param name [Symbol, String]
    # @param owner [ActiveRecord::Base, nil]
    # @return [Account]
    def self.lookup(name, owner: nil)
      find_by!(name: name, owner: owner)
    end

    # @param balance_type [Symbol]
    # @return [void]
    def self.balance_type(balance_type)
      case balance_type
      when :credit_normal
        after_initialize(if: :new_record?) { self.coefficient = CREDIT_NORMAL }
      when :debit_normal
        after_initialize(if: :new_record?) { self.coefficient = DEBIT_NORMAL }
      else
        raise ArgumentError, "Unsupported balance type: #{balance_type.inspect}. " \
                             '(Expected on of :credit_normal or :debit_normal.)'
      end
    end

    # @return [Boolean]
    def credit_normal?
      coefficient == CREDIT_NORMAL
    end

    # @return [Boolean]
    def debit_normal?
      coefficient == DEBIT_NORMAL
    end

    # Returns the balance for a given currency on this account.
    # If no balance is present for the specified currency, 0 is returned.
    #
    # @param currency [String]
    # @param at [Time, nil]
    # @return [Money]
    def balance(currency, at: nil)
      scope = operations.where(currency: currency)
      scope = scope.at_or_before(at) if at

      scope.last&.balance_after || Money.from_amount(0, currency)
    end

    # Returns the latest balances for all currencies on this account.
    #
    # @param at [Time, nil]
    # @return [Hash{String => Money}]
    def balances(at: nil)
      scope = operations.group(:currency).select(Operation.arel_table[:id].maximum)
      scope = scope.at_or_before(at) if at

      operations.where(id: scope)
        .map { |operation| [operation.currency, operation.balance_after] }
        .to_h
    end
  end
end
