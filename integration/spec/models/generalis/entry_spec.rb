# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Entry, type: :model do
  subject(:entry) { build(:entry) }

  it 'has a valid factory' do
    expect(entry).to be_valid
  end

  it 'is invalid without a transaction ID' do
    entry.transaction_id = nil
    expect(entry).to be_invalid
  end

  it 'is invalid when an entry exists with the same transaction ID' do
    create(:entry, transaction_id: entry.transaction_id)
    expect(entry).to be_invalid
  end

  it 'is invalid without operations' do
    entry.operations = []
    expect(entry).to be_invalid
  end

  it 'is invalid when the entry only has credit operations' do
    entry.operations = [build(:credit, entry: entry)]
    expect(entry).to be_invalid
  end

  it 'is invalid when the entry only has debit operations' do
    entry.operations = [build(:debit, entry: entry)]
    expect(entry).to be_invalid
  end

  it 'is invalid when the credit operations do not equal the debit operations' do
    entry.operations << build(:credit, entry: entry)
    expect(entry).to be_invalid
  end

  it 'properly handles an account being debited and credited in the same entry' do
    account = create(:account)
    entry.operations = [Generalis::Credit.new(account: account, amount: 100.00, currency: 'CAD'),
                        Generalis::Debit.new(account: account, amount: 100.00, currency: 'CAD')]
    entry.save!

    expect(account.balance('CAD')).to eq(0.00)
  end
end
