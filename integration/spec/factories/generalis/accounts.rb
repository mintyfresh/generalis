# frozen_string_literal: true

FactoryBot.define do
  factory :account, class: 'Generalis::Account' do
    type { 'Generalis::Account' }
    sequence(:name) { |n| "#{Faker::Book.title}.#{n}" }

    after(:build) do |account|
      account.coefficient ||= [Generalis::Account::CREDIT_NORMAL, Generalis::Account::DEBIT_NORMAL].sample
    end
  end
end
