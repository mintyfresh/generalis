# frozen_string_literal: true

module Generalis
  class Entry < ActiveRecord::Base
    require_relative 'entry/dsl'
    require_relative 'entry/links'

    extend Entry::DSL
    extend Entry::Links

    belongs_to :source, optional: true, polymorphic: true

    has_many :links, dependent: :destroy, inverse_of: :entry
    has_many :operations, dependent: :destroy, inverse_of: :entry
    has_many :accounts, through: :operations

    validates :transaction_id, presence: true, uniqueness: { on: :create }
    validates :operations, presence: true

    validate on: :create do
      errors.add(:base, :trial_balance_nonzero) if credit_amounts != debit_amounts
    end

    before_create do
      # Acquire locks on all participating accounts to calculate their balance.
      # Locks are acquired in a deterministic sequence to prevent deadlocks.
      operations.map(&:account).reject(&:new_record?).uniq.sort_by(&:id).each(&:lock!)
    end

    scope :at_or_before, -> (time) { where(occurred_at: ..time) }

    scope :with_account, lambda { |account|
      operations_on_account = Operation.where(account: account)
        .where(Operation.arel_table[:entry_id].eq(arel_table[:id]))

      where(operations_on_account.arel.exists)
    }

    scope :with_currency, lambda { |currency|
      operations_in_currency = Operation.where(currency: currency)
        .where(Operation.arel_table[:entry_id].eq(arel_table[:id]))

      where(operations_in_currency.arel.exists)
    }

    # @param source [ActiveRecord::Base]
    # #@return [Ledger::BaseEntry]
    def self.build_for(source)
      new(source: source)
    end

    # @param source [ActiveRecord::Base]
    # @return [Ledger::BaseEntry]
    def self.create_for(source)
      build_for(source).tap(&:save!)
    end

    # @return [Hash{String => Money}]
    def credit_amounts
      operations.select(&:credit?).group_by(&:currency).transform_values { |operations| operations.sum(&:amount) }
    end

    # @return [Hash{String => Money}]
    def debit_amounts
      operations.select(&:debit?).group_by(&:currency).transform_values { |operations| operations.sum(&:amount) }
    end
  end
end
