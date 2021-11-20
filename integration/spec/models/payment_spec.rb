# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  subject(:payment) { build(:payment) }

  it 'has a valid factory' do
    expect(payment).to be_valid
  end
end
