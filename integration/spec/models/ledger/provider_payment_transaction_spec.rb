# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ledger::ProviderPaymentTransaction, type: :model do
  subject(:transaction) { build(:provider_payment_transaction) }

  let(:payment) { transaction.payment }
  let(:provider) { payment.provider }

  it 'has a valid factory' do
    expect(transaction).to be_valid
  end

  it 'credits the payment amount to the company cash account' do
    expect(transaction).to credit_account(:cash)
      .with_amount(payment.amount)
  end

  it "debits the payment amount to the provider's payable account" do
    expect(transaction).to debit_account(provider.accounts_payable)
      .with_amount(payment.amount)
  end
end
