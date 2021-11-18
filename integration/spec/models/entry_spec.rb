# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id             :bigint           not null, primary key
#  type           :string
#  source_type    :string
#  source_id      :bigint
#  transaction_id :string           not null
#  description    :string
#  metadata       :jsonb
#  occurred_at    :datetime         not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_entries_on_source          (source_type,source_id)
#  index_entries_on_transaction_id  (transaction_id) UNIQUE
#
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

  it 'is invalid when the credit operations do not equal the debit operations' do
    entry.operations << build(:credit, entry: entry)
    expect(entry).to be_invalid
  end
end
