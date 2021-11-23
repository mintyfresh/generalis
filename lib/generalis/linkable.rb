# frozen_string_literal: true

module Generalis
  module Linkable
    extend ActiveSupport::Concern

    included do
      has_many :ledger_links, as: :linkable, class_name: 'Generalis::Link',
                              dependent: :restrict_with_error, inverse_of: :linkable

      has_many :linked_ledger_transactions, class_name: 'Generalis::Transaction',
                                            through: :ledger_links, source: :ledger_transaction
    end
  end
end
