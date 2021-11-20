# frozen_string_literal: true

FactoryBot.define do
  factory :order_placed_entry, class: 'Ledger::OrderPlacedEntry' do
    type { 'Ledger::OrderPlacedEntry' }
    order { create(:order) }
  end
end
