# frozen_string_literal: true

FactoryBot.define do
  factory :credit, class: 'Generalis::Credit', parent: :operation do
    type { 'Generalis::Credit' }
  end
end
