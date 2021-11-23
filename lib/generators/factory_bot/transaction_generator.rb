# frozen_string_literal: true

require 'rails/generators'

module FactoryBot
  module Generators
    class TransactionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def create_transaction_factory
        template 'transactions.rb.erb', "spec/factories/#{module_path}/#{file_name}.rb"
      end

      def file_name
        class_name.underscore.pluralize
      end

      def qualified_class_name
        "#{module_name}::#{class_name}"
      end

      def class_name
        "#{name.to_s.classify.chomp('Transaction')}Transaction"
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
    end
  end
end
