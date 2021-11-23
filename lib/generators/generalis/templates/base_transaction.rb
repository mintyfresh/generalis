# frozen_string_literal: true

module Ledger
  class BaseTransaction < Generalis::Transaction
    extend DSL
    extend Links

    self.abstract_class = true

    validates :type, presence: true
  end
end
