# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ledger::CustomerChargeEntry, type: :model do
  subject(:customer_charge_entry) { build(:customer_charge_entry) }

  let(:charge) { customer_charge_entry.charge }
  let(:customer) { charge.customer }

  it 'has a valid factory' do
    expect(customer_charge_entry).to be_valid
  end

  it "credits the charge amount to the customer's receivable account" do
    expect(customer_charge_entry).to credit_account(customer.accounts_receivable)
      .with_amount(charge.amount)
  end

  it 'debits the charge amount to the company cash account' do
    expect(customer_charge_entry).to debit_account(:cash)
      .with_amount(charge.amount)
  end
end
