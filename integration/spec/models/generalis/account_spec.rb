# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id          :bigint           not null, primary key
#  type        :string           not null
#  owner_type  :string
#  owner_id    :bigint
#  name        :string           not null
#  coefficient :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_accounts_on_name                              (name) UNIQUE WHERE (owner_id IS NULL)
#  index_accounts_on_owner                             (owner_type,owner_id)
#  index_accounts_on_owner_type_and_owner_id_and_name  (owner_type,owner_id,name) UNIQUE
#
require 'rails_helper'

RSpec.describe Generalis::Account, type: :model do
  subject(:account) { build(:account) }

  it 'has a valid factory' do
    expect(account).to be_valid
  end

  it 'is invalid without a name' do
    account.name = nil
    expect(account).to be_invalid
  end

  it 'is invalid without a coefficient' do
    account.coefficient = nil
    expect(account).to be_invalid
  end

  it 'is invalid when the coefficient is unsupported' do
    account.coefficient = 0
    expect(account).to be_invalid
  end

  describe '#balance' do
    subject(:balance) { account.balance(currency) }

    let(:currency) { 'CAD' }
    let(:account) { create(:account) }

    it 'returns zero when the account has no operations' do
      expect(balance).to be_zero
    end

    it 'returns the latest balance on the account with the specified currency' do
      operation = create(:operation, account: account, currency: currency)
      expect(balance).to eq(operation.balance_after)
    end

    it 'ignores balances associated with other currencies on the account' do
      operation = create(:operation, account: account, currency: 'USD')
      expect(balance).not_to eq(operation.balance_after)
    end

    it 'ignores balances associated with other accounts' do
      operation = create(:operation, currency: currency)
      expect(balance).not_to eq(operation.balance_after)
    end
  end
end
