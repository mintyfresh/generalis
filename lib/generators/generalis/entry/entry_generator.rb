# frozen_string_literal: true

require 'rails/generators'

module Generalis
  module Generators
    class EntryGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def create_entry_model
        template 'entry.rb.erb', "app/models/#{models_subpath}/#{file_name}.rb"
      end

      def file_name
        "#{name.to_s.underscore.chomp('_entry')}_entry"
      end

      def class_name
        [parent_module, file_name.classify].compact.join('::')
      end

      def models_subpath
        'ledger'
      end

      def parent_module
        models_subpath.classify
      end
    end
  end
end
