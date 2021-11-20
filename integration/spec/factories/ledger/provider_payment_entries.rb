# frozen_string_literal: true

FactoryBot.define do
  factory :provider_payment_entry, class: 'Ledger::ProviderPaymentEntry' do
    type { 'Ledger::ProviderPaymentEntry' }
    payment { create(:payment) }
  end
end
