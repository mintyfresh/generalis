# frozen_string_literal: true

class Ledger::OrderPlacedTransaction < Ledger::BaseTransaction
  has_one_linked :order

  transaction_id do
    "order-#{order.id}"
  end

  description do
    "Order ##{order.id} placed by #{customer.name} from #{provider.name} for #{order.total.format}"
  end

  occurred_at do
    order.created_at
  end

  metadata do
    # Optional: Any additional metadata to be stored with the transaction (an Array or Hash)
  end

  # CUSTOMER SIDE

  double_entry do |e|
    e.debit  = customer.accounts_receivable
    e.credit = Generalis::Revenue[:orders]
    e.amount = order.order_amount
  end

  double_entry do |e|
    e.debit  = customer.accounts_receivable
    e.credit = Generalis::Revenue[:delivery_fees]
    e.amount = order.delivery_fee
  end

  double_entry do |e|
    e.debit  = customer.accounts_receivable
    e.credit = Generalis::Revenue[:platform_fees]
    e.amount = order.platform_fee
  end

  # PROVIDER SIDE

  double_entry do |e|
    e.debit  = Generalis::Revenue[:orders]
    e.credit = provider.accounts_payable
    e.amount = order.order_amount
  end

  double_entry do |e|
    e.debit  = Generalis::Revenue[:delivery_fees]
    e.credit = provider.accounts_payable
    e.amount = order.delivery_fee
  end

  delegate :customer, :provider, to: :order
end
