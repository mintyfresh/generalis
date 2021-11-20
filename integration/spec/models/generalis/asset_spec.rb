# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Asset, type: :model do
  subject(:asset) { build(:asset) }

  it 'has a valid factory' do
    expect(asset).to be_valid
  end

  it 'is debit normal' do
    expect(asset).to be_debit_normal
  end
end
