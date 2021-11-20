# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Revenue, type: :model do
  subject(:revenue) { build(:revenue) }

  it 'has a valid factory' do
    expect(revenue).to be_valid
  end

  it 'is credit normal' do
    expect(revenue).to be_credit_normal
  end
end
