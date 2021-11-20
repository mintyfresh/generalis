# frozen_string_literal: true

FactoryBot.define do
  factory :operation, class: 'Generalis::Operation' do
    association :account, strategy: :create
    association :entry, strategy: :create

    type { 'Generalis::Operation' }
    currency { %w[CAD USD EUR].sample }
    amount { 100.00 }

    after(:build) do |operation|
      operation.coefficient ||= [Generalis::Operation::CREDIT, Generalis::Operation::DEBIT].sample
    end
  end
end
