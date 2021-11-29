# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    association :customer, strategy: :build
    association :provider, strategy: :build

    currency { %w[CAD USD EUR].sample }
    order_amount { Faker::Commerce.price }
    delivery_fee { [0.00, 5.00, 10.00, 20.00].sample }
    platform_fee { order_amount * 0.10 }

    after(:build) do |order|
      order.total = order.order_amount + order.delivery_fee + order.platform_fee
    end
  end
end
