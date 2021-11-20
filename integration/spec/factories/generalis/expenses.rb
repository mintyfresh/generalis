# frozen_string_literal: true

FactoryBot.define do
  factory :expense, class: 'Generalis::Expense', parent: :account do
    type { 'Generalis::Expense' }
  end
end
