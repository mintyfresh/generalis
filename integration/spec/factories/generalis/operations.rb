# frozen_string_literal: true

# == Schema Information
#
# Table name: operations
#
#  id                  :bigint           not null, primary key
#  type                :string           not null
#  account_id          :bigint           not null
#  entry_id            :bigint           not null
#  currency            :string           not null
#  amount_cents        :integer          not null
#  balance_after_cents :integer          not null
#  coefficient         :integer          not null
#  metadata            :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_operations_on_account_id                      (account_id)
#  index_operations_on_account_id_and_currency_and_id  (account_id,currency,id DESC)
#  index_operations_on_entry_id                        (entry_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (entry_id => entries.id)
#
FactoryBot.define do
  factory :operation, class: 'Generalis::Operation' do
    association :account, strategy: :create
    association :entry, strategy: :create

    type { 'Generalis::Operation' }
    currency { %w[CAD USD EUR].sample }
    amount { 100.00 }

    after(:build) do |operation|
      operation.coefficient ||= [Generalis::Operation::CREDIT, Generalis::Operation::DEBIT].sample
    end
  end
end
