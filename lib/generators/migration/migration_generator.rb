# frozen_string_literal: true

module Generalis
  class MigrationGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    source_root File.expand_path('templates', __dir__)

    def create_migration_files
      migration_template 'create_ledger_accounts.rb', 'db/migrate/create_ledger_accounts.rb'
      migration_template 'create_ledger_entries.rb', 'db/migrate/create_ledger_entries.rb'
      migration_template 'create_ledger_operations.rb', 'db/migrate/create_ledger_operations.rb'
      migration_template 'create_ledger_links.rb', 'db/migrate/create_ledger_links.rb'
    end
  end
end
