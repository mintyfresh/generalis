# frozen_string_literal: true

module Generalis
  class Transaction < ActiveRecord::Base
    autoload :DSL, 'generalis/transaction/dsl'
    autoload :Links, 'generalis/transaction/links'

    has_many :entries, dependent: :destroy, inverse_of: :ledger_transaction
    has_many :accounts, through: :entries

    has_many :links, dependent: :destroy, inverse_of: :ledger_transaction do
      def [](name)
        if name.is_a?(Symbol) || name.is_a?(String)
          find_by(name: name.to_s)
        else
          super
        end
      end
    end

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

    # @param attributes [Hash]
    # @return [void]
    def add_credit(attributes)
      raise 'Cannot modify persisted transactions' if persisted?

      entries << Credit.new(attributes)
    end

    # @param attributes [Hash]
    # @return [void]
    def add_debit(attributes)
      raise 'Cannot modify persisted transactions' if persisted?

      entries << Debit.new(attributes)
    end

    # @param credit_attributes [Hash]
    # @param debit_attributes [Hash]
    # @return [void]
    def add_double_entry(credit_attributes, debit_attributes)
      pair_id = SecureRandom.uuid

      add_credit(credit_attributes.merge(pair_id: pair_id))
      add_debit(debit_attributes.merge(pair_id: pair_id))
    end

    # @param name [Symbol, String]
    # @param record [ActiveRecord::Base]
    # @return [void]
    def add_link(name, record)
      links << Link.new(name: name, linkable: record)
    end

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
