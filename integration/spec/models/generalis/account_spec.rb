# frozen_string_literal: true

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

    it 'returns zero when the account has no entries' do
      expect(balance).to be_zero
    end

    it 'returns the latest balance on the account with the specified currency' do
      entry = create(:entry, account: account, currency: currency)
      expect(balance).to eq(entry.balance_after)
    end

    it 'ignores balances associated with other currencies on the account' do
      entry = create(:entry, account: account, currency: 'USD')
      expect(balance).not_to eq(entry.balance_after)
    end

    it 'ignores balances associated with other accounts' do
      entry = create(:entry, currency: currency)
      expect(balance).not_to eq(entry.balance_after)
    end
  end
end
