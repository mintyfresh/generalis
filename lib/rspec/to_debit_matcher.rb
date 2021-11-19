# frozen_string_literal: true

require_relative 'helpers/resolve_account_helper'
require_relative 'helpers/resolve_amount_helper'

RSpec::Matchers.define :to_debit do |account, owner: nil|
  include Generalis::RSpec::ResolveAccountHelper
  include Generalis::RSpec::ResolveAmountHelper

  match do |entry|
    entry.validate if entry.operations.none?

    account    = resolve_account(account, owner: owner)
    operations = entry.operations.select { |operation| operation.debit? && operation.account == account }

    operations.any? && matches_amount?(operations)
  end

  chain(:with_amount) do |amount, currency = nil|
    @amount = resolve_amount(amount, currency)
  end

  # @param operations [Array<Generalis::Operation>]
  # @return [Boolean]
  def matches_amount?(operations)
    return true if @amount.nil?

    operations
      .select { |operation| operation.currency.casecmp(@amount.currency).zero? }
      .sum(&:amount) == @amount
  end
end
