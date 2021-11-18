# frozen_string_literal: true

require 'rails/generators'

module Generalis
  module Generators
    class EntryGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def create_entry
        template 'entry.rb.erb', "app/models/#{module_path}/#{file_name}.rb"
      end

      def file_name
        class_name.underscore
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

      hook_for :test_framework
    end
  end
end
