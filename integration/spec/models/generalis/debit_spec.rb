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
