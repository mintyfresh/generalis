# frozen_string_literal: true

class Customer < ApplicationRecord
  include Generalis::Accountable

  has_many :charges, dependent: :restrict_with_error, inverse_of: :customer

  has_asset_account :accounts_receivable

  validates :name, presence: true
end
