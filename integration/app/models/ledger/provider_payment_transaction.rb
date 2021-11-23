# frozen_string_literal: true

class Ledger::ProviderPaymentTransaction < Ledger::BaseTransaction
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
    # Optional: Any additional metadata to be stored with the transaction (an Array or Hash)
  end

  double_entry do |e|
    e.debit  = provider.accounts_payable
    e.credit = Generalis::Asset[:cash]
    e.amount = payment.amount
  end

  delegate :provider, to: :payment
end
