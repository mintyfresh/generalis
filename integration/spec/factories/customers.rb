# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
  end
end
