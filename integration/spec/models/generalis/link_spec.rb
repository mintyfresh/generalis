# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Link, type: :model do
  subject(:link) { build(:link) }

  it 'has a valid factory' do
    expect(link).to be_valid
  end

  it 'is invalid without a transaction' do
    link.ledger_transaction = nil
    expect(link).to be_invalid
  end

  it 'is invalid without an linkable' do
    link.linkable = nil
    expect(link).to be_invalid
  end

  it 'is invalid without a name' do
    link.name = nil
    expect(link).to be_invalid
  end
end
