# frozen_string_literal: true

FactoryBot.define do
  factory :link, class: 'Generalis::Link' do
    association :ledger_transaction, factory: :transaction, strategy: :build
    association :linkable, factory: :account, strategy: :build

    name { 'test' }
  end
end
