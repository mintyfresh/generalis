# frozen_string_literal: true

require 'rails/generators'

module Rspec
  module Generators
    class EntryGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def create_entry_spec
        template 'entry_spec.rb.erb', "spec/models/#{module_path}/#{file_name}.rb"
      end

      def file_name
        "#{class_name.underscore}_spec"
      end

      def qualified_class_name
        "#{module_name}::#{class_name}"
      end

      def class_name
        "#{name.to_s.classify.chomp('Entry')}Entry"
      end

      def module_name
        module_path.classify
      end

      def module_path
        'ledger'
      end

      def factory_name
        class_name.underscore
      end

      hook_for :fixture_replacement
    end
  end
end
