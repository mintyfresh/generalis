# frozen_string_literal: true

class Ledger::BaseEntry < Generalis::Entry
  self.abstract_class = true

  validates :type, presence: true
end
