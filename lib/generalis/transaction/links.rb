# frozen_string_literal: true

module Generalis
  class Transaction < ActiveRecord::Base
    module Links
      # @param name [Symbol]
      # @param class_name [String]
      # @return [void]
      def has_one_linked(name, class_name: name.to_s.classify) # rubocop:disable Naming/PredicateName
        has_one :"#{name}_link", -> { where(name: name) },
                class_name: 'Generalis::Link', dependent: :destroy,
                foreign_key: :transaction_id, inverse_of: :ledger_transaction

        has_one name, through: :"#{name}_link", source: :linkable, source_type: class_name
      end

      # @param name [Symbol]
      # @param class_name [String]
      # @return [void]
      def has_many_linked(name, class_name: name.to_s.singularize.classify) # rubocop:disable Naming/PredicateName
        has_many :"#{name}_links", -> { where(name: name) },
                 class_name: 'Generalis::Link', dependent: :destroy,
                 foreign_key: :transaction_id, inverse_of: :ledger_transaction

        has_many name, through: :"#{name}_links", source: :linkable, source_type: class_name
      end
    end
  end
end
