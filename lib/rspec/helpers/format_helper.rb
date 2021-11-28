# frozen_string_literal: true

module Generalis
  module RSpec
    module FormatHelper
      # @param entry [Generalis::Entry]
      # @return [String]
      def format_entry(entry)
        "\t#{format_money(entry.amount)} to #{format_account(entry.account)}"
      end

      # @param account [Generalis::Account]
      # @return [String]
      def format_account(account)
        text  = "#{account.class}[:#{account.name}]"
        text += " (Owner: #{account.owner.class} #{account.owner.id})" if account.owner

        text
      end

      # @param money [Money]
      # @return [String]
      def format_money(money)
        "#{money.format} (#{money.currency})"
      end
    end
  end
end
