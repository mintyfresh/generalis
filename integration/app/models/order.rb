# frozen_string_literal: true

class Order < ApplicationRecord
  include Generalis::Linkable

  belongs_to :customer
  belongs_to :provider

  monetize :order_amount_cents,
           :delivery_fee_cents,
           :platform_fee_cents,
           :total_cents,
           with_model_currency: :currency,
           numericality: { greater_than_or_equal_to: 0 }

  validates :currency, presence: true
end
