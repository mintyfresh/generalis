# frozen_string_literal: true

class Ledger::OrderPlacedEntry < Ledger::BaseEntry
  alias_attribute :order, :source

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
    # Optional: Any additional metadata to be stored with the entry (an Array or Hash)
  end

  # CUSTOMER SIDE

  debit do |debit|
    debit.account = customer.accounts_receivable
    debit.amount  = order.total
  end

  credit do |credit|
    credit.account = Generalis::Revenue[:orders]
    credit.amount  = order.order_amount
  end

  credit do |credit|
    credit.account = Generalis::Revenue[:delivery_fees]
    credit.amount  = order.delivery_fee
  end

  credit do |credit|
    credit.account = Generalis::Revenue[:platform_fees]
    credit.amount  = order.platform_fee
  end

  # PROVIDER SIDE

  debit do |debit|
    debit.account = Generalis::Revenue[:orders]
    debit.amount  = order.order_amount
  end

  debit do |debit|
    debit.account = Generalis::Revenue[:delivery_fees]
    debit.amount  = order.delivery_fee
  end

  credit do |credit|
    credit.account = provider.accounts_payable
    # Platform fees are retained and not payable to provider.
    credit.amount  = order.total - order.platform_fee
  end

  delegate :customer, :provider, to: :order
end
