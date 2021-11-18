# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module Generalis
  module Generators
    class MigrationsGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      def self.next_migration_number(dir)
        ::ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      def create_migration_files
        migration_template 'create_ledger_accounts.rb', 'db/migrate/create_ledger_accounts.rb'
        migration_template 'create_ledger_entries.rb', 'db/migrate/create_ledger_entries.rb'
        migration_template 'create_ledger_operations.rb', 'db/migrate/create_ledger_operations.rb'
        migration_template 'create_ledger_links.rb', 'db/migrate/create_ledger_links.rb'
      end
    end
  end
end
