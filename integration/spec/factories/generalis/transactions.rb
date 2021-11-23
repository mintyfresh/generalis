# frozen_string_literal: true

FactoryBot.define do
  factory :transaction, class: 'Generalis::Transaction' do
    transaction_id { SecureRandom.uuid }
    description { Faker::Hipster.sentence }

    transient do
      currencies { %w[CAD USD EUR].sample(1) }
      amount { 100.00 }
    end

    after(:build) do |transaction, e|
      e.currencies.each do |currency|
        transaction.entries << build(:credit, ledger_transaction: transaction, currency: currency, amount: e.amount)
        transaction.entries << build(:debit,  ledger_transaction: transaction, currency: currency, amount: e.amount)
      end
    end
  end
end
