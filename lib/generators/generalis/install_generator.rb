# frozen_string_literal: true

require 'rails/generators'

module Generalis
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        template 'generalis.rb', 'config/initializers/generalis.rb'
      end

      def create_base_transaction
        template 'base_transaction.rb', 'app/models/ledger/base_transaction.rb'
      end
    end
  end
end
