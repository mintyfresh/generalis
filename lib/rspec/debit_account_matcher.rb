# frozen_string_literal: true

require_relative 'helpers/format_helper'
require_relative 'helpers/resolve_account_helper'
require_relative 'helpers/resolve_amount_helper'

RSpec::Matchers.define :debit_account do |account, owner: nil|
  include Generalis::RSpec::FormatHelper
  include Generalis::RSpec::ResolveAccountHelper
  include Generalis::RSpec::ResolveAmountHelper

  match do |transaction|
    transaction.prepare

    @account = resolve_account(account, owner: owner)
    entries = transaction.entries.select { |entry| entry.debit? && entry.account == @account }

    entries.any? && matches_amount?(entries)
  end

  chain(:with_amount) do |amount, currency = nil|
    @amount = resolve_amount(amount, currency)
  end

  failure_message do |transaction|
    message  = "expected transaction to debit account #{format_account(@account)}"
    message += " with amount #{format_money(@amount)}" if @amount
    message += "\n"
    message += "\nCredits:\n"
    message += transaction.entries.select(&:credit?).map { |entry| format_entry(entry) }.join("\n")
    message += "\nDebits:\n"
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
