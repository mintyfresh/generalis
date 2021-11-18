# frozen_string_literal: true

RSpec::Matchers.define :have_credited do
  match do |account, owner: nil|
    account = lookup_account(account, owner: owner)

    operations = account.operations.credit.order(:id)
    last       = operations.last

    block_arg.call
    operations = operations.after(last) if last

    operations.any? && matches_amount?(operations)
  end

  chain(:amount) do |amount, currency = nil|
    case amount
    when Money
      @amount = amount
    when Integer
      @amount = Money.from_cents(amount, currency)
    when Float, BigDecimal
      @amount = Money.from_amount(amount, currency)
    else
      raise ArgumentError, "Expected amount to be a Money, an Integer, a Float or a BigDecimal; got #{amount.inspect}"
    end
  end

private

  # @param locator [String, Symbol, Generalis::Account]
  # @param owner [ActiveRecord::Base, nil]
  # @return [Generalis::Account]
  def lookup_account(locator, owner: nil)
    case locator
    when Generalis::Account
      locator
    when String, Symbol
      Generalis::Account.lookup(locator, owner: owner)
    else
      raise ArgumentError, "Expected locator to be a Generalis::Account, a String or a Symbol; got #{locator.inspect}"
    end
  end

  # @param operations [Array<Generalis::Operation>]
  # @return [Boolean]
  def matches_amount?(operations)
    return true if @amount.nil?

    operations
      .select { |operation| operation.currency == @amount.currency }
      .sum(&:amount) == @amount
  end
end