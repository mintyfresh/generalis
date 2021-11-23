# frozen_string_literal: true

FactoryBot.define do
  factory :customer_charge_transaction, class: 'Ledger::CustomerChargeTransaction' do
    type { 'Ledger::CustomerChargeTransaction' }
    charge { create(:charge) }
  end
end
