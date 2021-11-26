# frozen_string_literal: true

require_relative 'helpers/format_entry_helper'
require_relative 'helpers/resolve_account_helper'
require_relative 'helpers/resolve_amount_helper'

RSpec::Matchers.define :credit_account do |account, owner: nil|
  include Generalis::RSpec::FormatEntryHelper
  include Generalis::RSpec::ResolveAccountHelper
  include Generalis::RSpec::ResolveAmountHelper

  match do |transaction|
    transaction.validate if transaction.entries.none?

    @account = resolve_account(account, owner: owner)
    entries = transaction.entries.select { |entry| entry.credit? && entry.account == @account }

    entries.any? && matches_amount?(entries)
  end

  chain(:with_amount) do |amount, currency = nil|
    @amount = resolve_amount(amount, currency)
  end

  failure_message do |transaction|
    message  = "expected transaction to credit account #{@account.class}[:#{@account.name}]"
    message += " with amount #{@amount.format} (#{@amount.currency})" if @amount
    message += "\n\n"
    message += "Credits:\n"
    message += transaction.entries.select(&:credit?).map { |entry| format_entry(entry) }.join("\n")
    message += "Debits:\n"
    message += transaction.entries.select(&:debit?).map { |entry| format_entry(entry) }.join("\n")
    message
  end

  # @param entries [Array<Generalis::Entry>]
  # @return [Boolean]
  def matches_amount?(entries)
    return true if @amount.nil?

    entries
      .select { |entry| entry.currency.casecmp(@amount.currency).zero? }
      .sum(&:amount) == @amount
  end
end
