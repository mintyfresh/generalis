# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Transaction, type: :model do
  subject(:transaction) { build(:transaction) }

  it 'has a valid factory' do
    expect(transaction).to be_valid
  end

  it 'is invalid without a transaction ID' do
    transaction.transaction_id = nil
    expect(transaction).to be_invalid
  end

  it 'is invalid when an transaction exists with the same transaction ID' do
    create(:transaction, transaction_id: transaction.transaction_id)
    expect(transaction).to be_invalid
  end

  it 'is invalid without operations' do
    transaction.operations = []
    expect(transaction).to be_invalid
  end

  it 'is invalid when the transaction only has credit operations' do
    transaction.operations = [build(:credit, ledger_transaction: transaction)]
    expect(transaction).to be_invalid
  end

  it 'is invalid when the transaction only has debit operations' do
    transaction.operations = [build(:debit, ledger_transaction: transaction)]
    expect(transaction).to be_invalid
  end

  it 'is invalid when the credit operations do not equal the debit operations' do
    transaction.operations << build(:credit, ledger_transaction: transaction)
    expect(transaction).to be_invalid
  end

  it 'properly handles an account being debited and credited in the same transaction' do
    account = create(:account)
    transaction.operations = [Generalis::Credit.new(account: account, amount: 100.00, currency: 'CAD'),
                              Generalis::Debit.new(account: account, amount: 100.00, currency: 'CAD')]
    transaction.save!

    expect(account.balance('CAD')).to eq(0.00)
  end
end
