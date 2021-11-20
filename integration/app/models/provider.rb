# frozen_string_literal: true

class Provider < ApplicationRecord
  include Generalis::Accountable

  has_many :payments, dependent: :restrict_with_error, inverse_of: :provider

  has_liability_account :accounts_payable

  validates :name, presence: true
end
