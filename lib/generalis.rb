# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext'

require_relative 'generalis/version'

module Generalis
  autoload :Account, 'generalis/account'
  autoload :Accountable, 'generalis/accountable'
  autoload :Asset, 'generalis/asset'
  autoload :Expense, 'generalis/expense'
  autoload :Liability, 'generalis/liability'
  autoload :Revenue, 'generalis/revenue'

  autoload :Entry, 'generalis/entry'
  autoload :Link, 'generalis/link'

  autoload :Operation, 'generalis/operation'
  autoload :Credit, 'generalis/credit'
  autoload :Debit, 'generalis/debit'

  # @return [Hash{String => Integer}]
  def self.trial_balances
    subquery = Operation
      .group(:account_id, :currency)
      .select(Operation.arel_table[:id].maximum)

    Operation
      .joins(:account)
      .where(id: subquery)
      .group(:currency)
      .sum((Operation.arel_table[:balance_after_cents] * Account.arel_table[:coefficient]))
  end

  def self.table_name_prefix
    'ledger_'
  end
end
