# frozen_string_literal: true

require_relative 'helpers/format_helper'
require_relative 'helpers/resolve_account_helper'
require_relative 'helpers/resolve_amount_helper'

RSpec::Matchers.define :have_balance do |amount, currency = nil|
  include Generalis::RSpec::FormatHelper
  include Generalis::RSpec::ResolveAccountHelper
  include Generalis::RSpec::ResolveAmountHelper

  match do |account, owner: nil|
    @account = resolve_account(account, owner: owner)
    @amount  = resolve_amount(amount, currency)

    values_match?(@account.balance(@amount.currency.to_s), @amount)
  end

  failure_message do
    message = "expected #{format_account(@account)} to have balance #{format_money(@amount)}\n"
    message + "\tactual balance was #{format_money(@account.balance(@amount.currency.to_s))}"
  end

  failure_message_when_negated do
    "expected #{format_account(@account)} not to have balance #{format_money(@amount)}"
  end
end
