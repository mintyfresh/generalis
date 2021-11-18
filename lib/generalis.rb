# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext'

require_relative 'generalis/version'

module Generalis
  def self.table_name_prefix
    'ledger_'
  end

  autoload :Account, 'generalis/account'
  autoload :Asset, 'generalis/asset'
  autoload :Expense, 'generalis/expense'
  autoload :Liability, 'generalis/liability'
  autoload :Revenue, 'generalis/revenue'

  autoload :Entry, 'generalis/entry'
  autoload :Link, 'generalis/link'

  autoload :Operation, 'generalis/operation'
  autoload :Credit, 'generalis/credit'
  autoload :Debit, 'generalis/debit'
end
