# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :provider

  validates :currency, presence: true

  monetize :amount_cents, with_model_currency: :currency, numericality: { greater_than: 0 }
end
