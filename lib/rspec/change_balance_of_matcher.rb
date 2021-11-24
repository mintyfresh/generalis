# frozen_string_literal: true

require_relative 'helpers/resolve_account_helper'
require_relative 'helpers/resolve_amount_helper'

RSpec::Matchers.define :change_balance_of do |account, owner: nil|
  include Generalis::RSpec::ResolveAccountHelper
  include Generalis::RSpec::ResolveAmountHelper

  match do |transaction|
    transaction.validate if transaction.entries.none?

    account = resolve_account(account, owner: owner)
    entries = transaction.entries.select { |entry| entry.account == account }

    entries.any? && matches_amount?(entries)
  end

  chain(:by) do |amount, currency = nil|
    @amount = resolve_amount(amount, currency)
  end

  # @param entries [Array<Generalis::Entry>]
  # @return [Boolean]
  def matches_amount?(entries)
    return entries.group_by(&:currency).values.any? { |bucket| bucket.sum(&:net_amount).nonzero? } if @amount.nil?

    entries
      .select { |entry| entry.currency.casecmp(@amount.currency).zero? }
      .sum(&:net_amount) == @amount
  end
end
