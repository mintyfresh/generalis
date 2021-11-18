# frozen_string_literal: true

RSpec::Matchers.define :have_balance do |amount, currency = nil|
  match do |account, owner: nil|
    account = resolve_account(account, owner: owner)
    amount  = resolve_amount(amount, currency)

    account.balance(amount.currency) == amount
  end

  def resolve_account(locator, owner:)
    case locator
    when Generalis::Account
      locator
    when String, Symbol
      Generalis::Account.lookup(account, owner: owner)
    else
      raise ArgumentError, "Expected a Generalis::Account, String, or Symbol, got #{account.inspect}"
    end
  end

  def resolve_amount(amount, currency)
    case amount
    when Money
      amount
    when Numeric
      Money.from_amount(amount, currency)
    else
      raise ArgumentError, "Expected a Money or Numeric, got #{amount.inspect}"
    end
  end
end
