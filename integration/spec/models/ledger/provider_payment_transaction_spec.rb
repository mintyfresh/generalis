# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ledger::ProviderPaymentTransaction, type: :model do
  subject(:provider_payment_transaction) { build(:provider_payment_transaction) }

  let(:payment) { provider_payment_transaction.payment }
  let(:provider) { payment.provider }

  it 'has a valid factory' do
    expect(provider_payment_transaction).to be_valid
  end

  it 'credits the payment amount to the company cash account' do
    expect(provider_payment_transaction).to credit_account(:cash)
      .with_amount(payment.amount)
  end

  it "debits the payment amount to the provider's payable account" do
    expect(provider_payment_transaction).to debit_account(provider.accounts_payable)
      .with_amount(payment.amount)
  end
end
