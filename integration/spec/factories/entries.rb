# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id             :bigint           not null, primary key
#  type           :string
#  source_type    :string
#  source_id      :bigint
#  transaction_id :string           not null
#  description    :string
#  metadata       :jsonb
#  occurred_at    :datetime         not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_entries_on_source          (source_type,source_id)
#  index_entries_on_transaction_id  (transaction_id) UNIQUE
#
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
