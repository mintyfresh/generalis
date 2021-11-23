# frozen_string_literal: true

FactoryBot.define do
  factory :debit, class: 'Generalis::Debit', parent: :entry do
    type { 'Generalis::Debit' }
  end
end
