# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ledger::ProviderPaymentEntry, type: :model do
  subject(:provider_payment_entry) { build(:provider_payment_entry) }

  let(:payment) { provider_payment_entry.payment }
  let(:provider) { payment.provider }

  it 'has a valid factory' do
    expect(provider_payment_entry).to be_valid
  end

  it 'credits the payment amount to the company cash account' do
    expect(provider_payment_entry).to credit_account(:cash)
      .with_amount(payment.amount)
  end

  it "debits the payment amount to the provider's payable account" do
    expect(provider_payment_entry).to debit_account(provider.accounts_payable)
      .with_amount(payment.amount)
  end
end
