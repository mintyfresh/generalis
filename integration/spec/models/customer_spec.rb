# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Customer, type: :model do
  subject(:customer) { build(:customer) }

  it 'has a valid factory' do
    expect(customer).to be_valid
  end

  it 'creates an accounts receivable asset account' do
    customer.save!
    expect(customer.accounts_receivable).to be_persisted
      .and be_a(Generalis::Asset)
  end
end
