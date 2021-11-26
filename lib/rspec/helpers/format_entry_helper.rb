# frozen_string_literal: true

module Generalis
  module RSpec
    module FormatEntryHelper
      # @param entry [Ledger::Entry]
      # @return [String]
      def format_entry(entry)
        text  = "\t#{entry.amount.format} (#{entry.amount.currency}) to #{entry.account.class}[:#{entry.account.name}]"
        text += " (Owner #{entry.account.owner.class} #{entry.account.owner.id})" if entry.account.owner
        text += "\n"

        text
      end
    end
  end
end
