# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Liability, type: :model do
  subject(:liability) { build(:liability) }

  it 'has a valid factory' do
    expect(liability).to be_valid
  end

  it 'is credit normal' do
    expect(liability).to be_credit_normal
  end
end
