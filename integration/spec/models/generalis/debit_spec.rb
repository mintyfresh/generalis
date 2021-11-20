# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Debit, type: :model do
  subject(:debit) { build(:debit) }

  it 'has a valid factory' do
    expect(debit).to be_valid
  end

  describe '#net_amount' do
    subject(:net_amount) { debit.net_amount }

    it 'increases the balance of asset accounts' do
      debit.account = build(:asset)
      expect(net_amount).to be_positive
    end

    it 'increases the balance of expense accounts' do
      debit.account = build(:expense)
      expect(net_amount).to be_positive
    end

    it 'decreases the balance of liability accounts' do
      debit.account = build(:liability)
      expect(net_amount).to be_negative
    end

    it 'decreases the balance of revenue accounts' do
      debit.account = build(:revenue)
      expect(net_amount).to be_negative
    end
  end
end
