# frozen_string_literal: true

FactoryBot.define do
  factory :revenue, class: 'Generalis::Revenue', parent: :account do
    type { 'Generalis::Revenue' }
  end
end
