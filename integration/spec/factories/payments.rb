# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    association :provider, strategy: :build

    currency { %w[CAD USD EUR].sample }
    amount { 100.00 }
  end
end
