# frozen_string_literal: true

FactoryBot.define do
  factory :customer_charge_entry, class: 'Ledger::CustomerChargeEntry' do
    type { 'Ledger::CustomerChargeEntry' }
    charge { create(:charge) }
  end
end
