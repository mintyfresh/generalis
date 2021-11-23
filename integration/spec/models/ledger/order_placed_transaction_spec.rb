# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ledger::OrderPlacedTransaction, type: :model do
  subject(:order_placed_transaction) { build(:order_placed_transaction) }

  let(:order) { order_placed_transaction.order }
  let(:customer) { order.customer }
  let(:provider) { order.provider }

  it 'has a valid factory' do
    expect(order_placed_transaction).to be_valid
  end

  it "debits the order total to the customer's receivable account" do
    expect(order_placed_transaction).to debit_account(customer.accounts_receivable)
      .with_amount(order.total)
  end

  it 'credits the goods portion of the order to the orders revenue account' do
    expect(order_placed_transaction).to credit_account(:orders)
      .with_amount(order.order_amount)
  end

  it 'credits the delivery fees of the order to the orders revenue account' do
    expect(order_placed_transaction).to credit_account(:delivery_fees)
      .with_amount(order.delivery_fee)
  end

  it 'credits the platform fees of the order to the orders revenue account' do
    expect(order_placed_transaction).to credit_account(:platform_fees)
      .with_amount(order.platform_fee)
  end

  it 'debits the goods portion of the order to the orders revenue account' do
    expect(order_placed_transaction).to debit_account(:orders)
      .with_amount(order.order_amount)
  end

  it 'debits the delivery fees of the order to the orders revenue account' do
    expect(order_placed_transaction).to debit_account(:delivery_fees)
      .with_amount(order.delivery_fee)
  end

  it "credits the order total less any platform fees to the provider's payable account" do
    expect(order_placed_transaction).to credit_account(provider.accounts_payable)
      .with_amount(order.total - order.platform_fee)
  end

  it 'leaves the orders revenue account with a zero balance' do
    order_placed_transaction.save!
    expect(Generalis::Revenue[:orders]).to have_balance(0.00, order.currency)
  end

  it 'leaves the delivery fees revenue account with a zero balance' do
    order_placed_transaction.save!
    expect(Generalis::Revenue[:delivery_fees]).to have_balance(0.00, order.currency)
  end

  it 'retains the platform fee in the platform fees revenue account' do
    order_placed_transaction.save!
    expect(Generalis::Revenue[:platform_fees]).to have_balance(order.platform_fee)
  end
end
