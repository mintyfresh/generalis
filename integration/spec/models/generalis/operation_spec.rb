# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Operation, type: :model do
  subject(:operation) { build(:operation) }

  it 'has a valid factory' do
    expect(operation).to be_valid
  end

  it 'is invalid without an account' do
    operation.account = nil
    expect(operation).to be_invalid
  end

  it 'is invalid without a transaction' do
    operation.ledger_transaction = nil
    expect(operation).to be_invalid
  end

  it 'is invalid without a currency' do
    operation.currency = nil
    expect(operation).to be_invalid
  end

  it 'is invalid without an amount' do
    operation.amount_cents = nil
    expect(operation).to be_invalid
  end

  it 'is valid when the amount is zero' do
    operation.amount = 0
    expect(operation).to be_valid
  end

  it 'is invalid when the amount is negative' do
    operation.amount = -100.00
    expect(operation).to be_invalid
  end

  it 'is invalid without a coefficient' do
    operation.coefficient = nil
    expect(operation).to be_invalid
  end

  it 'is invalid when the coefficient is unsupported' do
    operation.coefficient = 0
    expect(operation).to be_invalid
  end

  it 'calculates and stores the balance after the operation' do
    expect { operation.save }.to change { operation.balance_after }
      .to(operation.account.balance(operation.currency) + operation.net_amount)
  end
end
