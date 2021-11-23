# frozen_string_literal: true

FactoryBot.define do
  factory :provider_payment_transaction, class: 'Ledger::ProviderPaymentTransaction' do
    type { 'Ledger::ProviderPaymentTransaction' }
    payment { create(:payment) }
  end
end
