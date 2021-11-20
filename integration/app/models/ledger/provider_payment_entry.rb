# frozen_string_literal: true

class Ledger::ProviderPaymentEntry < Ledger::BaseEntry
  has_one_linked :payment

  transaction_id do
    "payment-#{payment.id}"
  end

  description do
    "Payment ##{payment.id} to #{provider.name} for #{payment.amount.format}"
  end

  occurred_at do
    payment.created_at
  end

  metadata do
    # Optional: Any additional metadata to be stored with the entry (an Array or Hash)
  end

  credit do |credit|
    credit.account = Generalis::Asset[:cash]
    credit.amount  = payment.amount
  end

  debit do |debit|
    debit.account = provider.accounts_payable
    debit.amount  = payment.amount
  end

  delegate :provider, to: :payment
end
