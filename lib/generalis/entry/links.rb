# frozen_string_literal: true

module Generalis
  class Entry < ActiveRecord::Base
    module Links
      # @param name [Symbol]
      # @param class_name [String]
      # @return [void]
      def has_one_linked(name, class_name: name.to_s.camelize) # rubocop:disable Naming/PredicateName
        has_one :"#{name}_link", -> { where(name: name) },
                class_name: 'Generalis::Link', dependent: false,
                foreign_key: :entry_id, inverse_of: :entry

        has_one name, through: :"#{name}_link", source: :linkable, source_type: class_name
      end

      # @param name [Symbol]
      # @param class_name [String]
      # @return [void]
      def has_many_linked(name, class_name: name.to_s.camelize) # rubocop:disable Naming/PredicateName
        has_many :"#{name}_links", -> { where(name: name) },
                 class_name: 'Generalis::Link', dependent: false,
                 foreign_key: :entry_id, inverse_of: :entry

        has_many name, through: :"#{name}_links", source: :linkable, source_type: class_name
      end
    end
  end
end
