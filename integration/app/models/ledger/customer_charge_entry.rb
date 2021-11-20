# frozen_string_literal: true

class Ledger::CustomerChargeEntry < Ledger::BaseEntry
  alias_attribute :charge, :source

  transaction_id do
    "charge-#{charge.id}"
  end

  description do
    "Charge ##{charge.id} to #{customer.name} for #{charge.amount.format}"
  end

  occurred_at do
    charge.created_at
  end

  metadata do
    # Optional: Any additional metadata to be stored with the entry (an Array or Hash)
  end

  credit do |credit|
    credit.account = customer.accounts_receivable
    credit.amount  = charge.amount
  end

  debit do |debit|
    debit.account = Generalis::Asset[:cash]
    debit.amount  = charge.amount
  end

  delegate :customer, to: :charge
end
