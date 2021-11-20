# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generalis::Expense, type: :model do
  subject(:expense) { build(:expense) }

  it 'has a valid factory' do
    expect(expense).to be_valid
  end

  it 'is debit normal' do
    expect(expense).to be_debit_normal
  end
end
