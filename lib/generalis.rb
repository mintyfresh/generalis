# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext'

require_relative 'generalis/config'
require_relative 'generalis/version'

module Generalis
  autoload :Account, 'generalis/account'
  autoload :Accountable, 'generalis/accountable'
  autoload :Asset, 'generalis/asset'
  autoload :Expense, 'generalis/expense'
  autoload :Liability, 'generalis/liability'
  autoload :Revenue, 'generalis/revenue'

  autoload :Transaction, 'generalis/transaction'
  autoload :Link, 'generalis/link'
  autoload :Linkable, 'generalis/linkable'

  autoload :Entry, 'generalis/entry'
  autoload :Credit, 'generalis/credit'
  autoload :Debit, 'generalis/debit'

  # @return [Hash{String => Integer}]
  def self.trial_balances
    subquery = Entry
      .group(:account_id, :currency)
      .select(Entry.arel_table[:id].maximum)

    Entry
      .joins(:account)
      .where(id: subquery)
      .group(:currency)
      .sum((Entry.arel_table[:balance_after_cents] * Account.arel_table[:coefficient]))
  end

  # @return [Config]
  def self.config
    @config ||= Config.new.freeze
  end

  # @return [void]
  def self.configure
    config = Config.new
    yield(config)

    @config = config.freeze
  end

  # @return [String]
  def self.table_name_prefix
    config.table_name_prefix
  end
end
