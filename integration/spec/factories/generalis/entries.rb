# frozen_string_literal: true

FactoryBot.define do
  factory :entry, class: 'Generalis::Entry' do
    association :account, strategy: :create
    association :ledger_transaction, factory: :transaction, strategy: :create

    type { 'Generalis::Entry' }
    currency { %w[CAD USD EUR].sample }
    amount { 100.00 }

    after(:build) do |entry|
      entry.coefficient ||= [Generalis::Entry::CREDIT, Generalis::Entry::DEBIT].sample
    end
  end
end
