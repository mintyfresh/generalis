# frozen_string_literal: true

require_relative 'entry/dsl'
require_relative 'entry/links'

# == Schema Information
#
# Table name: ledger_entries
#
#  id             :bigint           not null, primary key
#  type           :string
#  source_type    :string
#  source_id      :bigint
#  transaction_id :string           not null
#  description    :string
#  metadata       :jsonb
#  occurred_at    :datetime         not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_ledger_entries_on_source          (source_type,source_id)
#  index_ledger_entries_on_transaction_id  (transaction_id) UNIQUE
#
module Generalis
  class Entry < ActiveRecord::Base
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
