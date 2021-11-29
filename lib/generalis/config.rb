# frozen_string_literal: true

require 'singleton'

module Generalis
  class Config
    # @param value [String]
    attr_writer :table_name_prefix

    # @return [String]
    def table_name_prefix
      @table_name_prefix || 'ledger_'
    end
  end
end
