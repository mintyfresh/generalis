# frozen_string_literal: true

FactoryBot.define do
  factory :entry, class: 'Generalis::Entry' do
    transaction_id { SecureRandom.uuid }
    description { Faker::Hipster.sentence }

    transient do
      currencies { %w[CAD USD EUR].sample(1) }
      amount { 100.00 }
    end

    after(:build) do |entry, e|
      e.currencies.each do |currency|
        entry.operations << build(:credit, entry: entry, currency: currency, amount: e.amount)
        entry.operations << build(:debit,  entry: entry, currency: currency, amount: e.amount)
      end
    end
  end
end
