# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Entry, type: :model do
  subject(:entry) { build(:entry) }

  it 'has a valid factory' do
    expect(entry).to be_valid
  end

  it 'is invalid without an account' do
    entry.account = nil
    expect(entry).to be_invalid
  end

  it 'is invalid without a transaction' do
    entry.ledger_transaction = nil
    expect(entry).to be_invalid
  end

  it 'is invalid without a currency' do
    entry.currency = nil
    expect(entry).to be_invalid
  end

  it 'is invalid without an amount' do
    entry.amount_cents = nil
    expect(entry).to be_invalid
  end

  it 'is valid when the amount is zero' do
    entry.amount = 0
    expect(entry).to be_valid
  end

  it 'is invalid when the amount is negative' do
    entry.amount = -100.00
    expect(entry).to be_invalid
  end

  it 'is invalid without a coefficient' do
    entry.coefficient = nil
    expect(entry).to be_invalid
  end

  it 'is invalid when the coefficient is unsupported' do
    entry.coefficient = 0
    expect(entry).to be_invalid
  end

  it 'calculates and stores the balance after the entry' do
    expect { entry.save }.to change { entry.balance_after }
      .to(entry.account.balance(entry.currency) + entry.net_amount)
  end
end
