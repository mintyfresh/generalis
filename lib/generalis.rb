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
    subquery = Operation.select(:account_id, :balance_after_cents, :currency, Arel.sql(<<-SQL.squish))
      RANK() OVER (
        PARTITION BY #{Operation.quoted_table_name}.account_id, #{Operation.quoted_table_name}.currency
        ORDER BY #{Operation.quoted_table_name}.id DESC
      ) AS rank
    SQL

    Operation.from(subquery, Operation.quoted_table_name)
      .joins(:account).where(rank: 1)
      .group(:currency)
      .sum(Operation.arel_table[:balance_after_cents] * Account.arel_table[:coefficient])
  end

  def self.table_name_prefix
    'ledger_'
  end
end
