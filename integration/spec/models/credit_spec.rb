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
