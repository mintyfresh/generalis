# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charge, type: :model do
  subject(:charge) { build(:charge) }

  it 'has a valid factory' do
    expect(charge).to be_valid
  end
end
