# frozen_string_literal: true

FactoryBot.define do
  factory :provider do
    name { Faker::Company.name }
  end
end
