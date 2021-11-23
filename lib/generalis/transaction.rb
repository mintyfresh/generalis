# frozen_string_literal: true

module Generalis
  class Transaction < ActiveRecord::Base
    autoload :DSL, 'generalis/transaction/dsl'
    autoload :Links, 'generalis/transaction/links'

    has_many :links, dependent: :destroy, inverse_of: :ledger_transaction
    has_many :entries, dependent: :destroy, inverse_of: :ledger_transaction
    has_many :accounts, through: :entries

    validates :transaction_id, presence: true, uniqueness: { on: :create }
    validates :entries, presence: true

    validate on: :create do
      errors.add(:base, :trial_balance_nonzero) if credit_amounts != debit_amounts
    end

    before_create do
      # Acquire locks on all participating accounts to calculate their balance.
      # Locks are acquired in a deterministic sequence to prevent deadlocks.
      entries.map(&:account).reject(&:new_record?).uniq.sort_by(&:id).each(&:lock!)
    end

    scope :at_or_before, -> (time) { where(occurred_at: ..time) }

    scope :with_account, lambda { |account|
      entries_on_account = Entry.where(account: account)
        .where(Entry.arel_table[:transaction_id].eq(arel_table[:id]))

      where(entries_on_account.arel.exists)
    }

    scope :with_currency, lambda { |currency|
      entries_in_currency = Entry.where(currency: currency)
        .where(Entry.arel_table[:transaction_id].eq(arel_table[:id]))

      where(entries_in_currency.arel.exists)
    }

    # @return [Hash{String => Money}]
    def credit_amounts
      entries.select(&:credit?).group_by(&:currency).transform_values { |entries| entries.sum(&:amount) }
    end

    # @return [Hash{String => Money}]
    def debit_amounts
      entries.select(&:debit?).group_by(&:currency).transform_values { |entries| entries.sum(&:amount) }
    end
  end
end
