# frozen_string_literal: true

module Ledger
  class BaseEntry < Generalis::Entry
    self.abstract_class = true

    validates :type, presence: true
  end
end
