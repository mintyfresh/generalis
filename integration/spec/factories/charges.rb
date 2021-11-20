# frozen_string_literal: true

FactoryBot.define do
  factory :charge do
    association :customer, strategy: :build

    currency { %w[CAD USD EUR].sample }
    amount { 100.00 }
  end
end
