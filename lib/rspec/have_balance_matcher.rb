# frozen_string_literal: true

require_relative 'helpers/resolve_account_helper'
require_relative 'helpers/resolve_amount_helper'

RSpec::Matchers.define :have_balance do |amount, currency = nil|
  include Generalis::RSpec::ResolveAccountHelper
  include Generalis::RSpec::ResolveAmountHelper

  match do |account, owner: nil|
    account = resolve_account(account, owner: owner)
    amount  = resolve_amount(amount, currency)

    account.balance(amount.currency) == amount
  end
end
