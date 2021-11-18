# frozen_string_literal: true

require 'rails/generators'

module Generalis
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        template 'generalis.rb', 'config/initializers/generalis.rb'
      end

      def create_base_entry
        template 'base_entry.rb', 'app/models/ledger/base_entry.rb'
      end
    end
  end
end
