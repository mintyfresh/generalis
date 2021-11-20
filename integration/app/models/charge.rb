# frozen_string_literal: true

class Charge < ApplicationRecord
  include Generalis::Linkable

  belongs_to :customer

  validates :currency, presence: true

  monetize :amount_cents, with_model_currency: :currency, numericality: { greater_than: 0 }
end
