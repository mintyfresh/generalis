# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id          :bigint           not null, primary key
#  type        :string           not null
#  owner_type  :string
#  owner_id    :bigint
#  name        :string           not null
#  coefficient :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_accounts_on_name                              (name) UNIQUE WHERE (owner_id IS NULL)
#  index_accounts_on_owner                             (owner_type,owner_id)
#  index_accounts_on_owner_type_and_owner_id_and_name  (owner_type,owner_id,name) UNIQUE
#
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
