# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject(:provider) { build(:provider) }

  it 'has a valid factory' do
    expect(provider).to be_valid
  end

  it 'creates an accounts payable liability account' do
    provider.save!
    expect(provider.accounts_payable).to be_persisted
      .and be_a(Generalis::Liability)
  end
end
