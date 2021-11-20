# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Credit, type: :model do
  subject(:credit) { build(:credit) }

  it 'has a valid factory' do
    expect(credit).to be_valid
  end

  describe '#net_amount' do
    subject(:net_amount) { credit.net_amount }

    it 'decreases the balance of asset accounts' do
      credit.account = build(:asset)
      expect(net_amount).to be_negative
    end

    it 'decreases the balance of expense accounts' do
      credit.account = build(:expense)
      expect(net_amount).to be_negative
    end

    it 'increases the balance of liability accounts' do
      credit.account = build(:liability)
      expect(net_amount).to be_positive
    end

    it 'increases the balance of revenue accounts' do
      credit.account = build(:revenue)
      expect(net_amount).to be_positive
    end
  end
end
