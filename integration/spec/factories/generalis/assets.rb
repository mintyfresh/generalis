# frozen_string_literal: true

FactoryBot.define do
  factory :asset, class: 'Generalis::Asset', parent: :account do
    type { 'Generalis::Asset' }
  end
end
