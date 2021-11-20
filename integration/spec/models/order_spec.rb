# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { build(:order) }

  it 'has a valid factory' do
    expect(order).to be_valid
  end
end
