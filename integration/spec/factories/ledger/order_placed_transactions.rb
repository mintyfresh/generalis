# frozen_string_literal: true

FactoryBot.define do
  factory :order_placed_transaction, class: 'Ledger::OrderPlacedTransaction' do
    type { 'Ledger::OrderPlacedTransaction' }
    order { create(:order) }
  end
end
