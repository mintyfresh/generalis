# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ledger::CustomerChargeTransaction, type: :model do
  subject(:transaction) { build(:customer_charge_transaction) }

  let(:charge) { transaction.charge }
  let(:customer) { charge.customer }

  it 'has a valid factory' do
    expect(transaction).to be_valid
  end

  it "credits the charge amount to the customer's receivable account" do
    expect(transaction).to credit_account(customer.accounts_receivable)
      .with_amount(charge.amount)
  end

  it 'debits the charge amount to the company cash account' do
    expect(transaction).to debit_account(:cash)
      .with_amount(charge.amount)
  end
end
