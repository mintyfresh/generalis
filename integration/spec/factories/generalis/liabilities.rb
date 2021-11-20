# frozen_string_literal: true

FactoryBot.define do
  factory :liability, class: 'Generalis::Liability', parent: :account do
    type { 'Generalis::Liability' }
  end
end
