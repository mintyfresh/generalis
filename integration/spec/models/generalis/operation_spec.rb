# frozen_string_literal: true

# == Schema Information
#
# Table name: operations
#
#  id                  :bigint           not null, primary key
#  type                :string           not null
#  account_id          :bigint           not null
#  entry_id            :bigint           not null
#  currency            :string           not null
#  amount_cents        :integer          not null
#  balance_after_cents :integer          not null
#  coefficient         :integer          not null
#  metadata            :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_operations_on_account_id                      (account_id)
#  index_operations_on_account_id_and_currency_and_id  (account_id,currency,id DESC)
#  index_operations_on_entry_id                        (entry_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (entry_id => entries.id)
#
require 'rails_helper'

RSpec.describe Generalis::Operation, type: :model do
  subject(:operation) { build(:operation) }

  it 'has a valid factory' do
    expect(operation).to be_valid
  end

  it 'is invalid without an account' do
    operation.account = nil
    expect(operation).to be_invalid
  end

  it 'is invalid without an entry' do
    operation.entry = nil
    expect(operation).to be_invalid
  end

  it 'is invalid without a currency' do
    operation.currency = nil
    expect(operation).to be_invalid
  end

  it 'is invalid without an amount' do
    operation.amount_cents = nil
    expect(operation).to be_invalid
  end

  it 'is valid when the amount is zero' do
    operation.amount = 0
    expect(operation).to be_valid
  end

  it 'is invalid when the amount is negative' do
    operation.amount = -100.00
    expect(operation).to be_invalid
  end

  it 'is invalid without a coefficient' do
    operation.coefficient = nil
    expect(operation).to be_invalid
  end

  it 'is invalid when the coefficient is unsupported' do
    operation.coefficient = 0
    expect(operation).to be_invalid
  end

  it 'calculates and stores the balance after the operation' do
    expect { operation.save }.to change { operation.balance_after }
      .to(operation.account.balance(operation.currency) + operation.net_amount)
  end
end
