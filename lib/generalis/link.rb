# frozen_string_literal: true

module Generalis
  class Link < ActiveRecord::Base
    belongs_to :ledger_transaction, class_name: 'Transaction', foreign_key: :transaction_id, inverse_of: :links
    belongs_to :linkable, polymorphic: true

    validates :name, presence: true
  end
end
