# frozen_string_literal: true

module Generalis
  module Accountable
    extend ActiveSupport::Concern

    included do
      has_many :ledger_accounts, as: :owner, class_name: 'Generalis::Account', dependent: false, inverse_of: :owner
      has_many :ledger_entries, through: :ledger_accounts, source: :entries
      has_many :ledger_transactions, through: :ledger_accounts
    end

    class_methods do
      # rubocop:disable Naming/PredicateName
      def has_asset_account(name, auto_create: true, dependent: :restrict_with_error)
        has_account(name, class_name: 'Generalis::Asset', auto_create: auto_create, dependent: dependent)
      end

      def has_expense_account(name, auto_create: true, dependent: :restrict_with_error)
        has_account(name, class_name: 'Generalis::Expense', auto_create: auto_create, dependent: dependent)
      end

      def has_liability_account(name, auto_create: true, dependent: :restrict_with_error)
        has_account(name, class_name: 'Generalis::Liability', auto_create: auto_create, dependent: dependent)
      end

      def has_revenue_account(name, auto_create: true, dependent: :restrict_with_error)
        has_account(name, class_name: 'Generalis::Revenue', auto_create: auto_create, dependent: dependent)
      end

    private

      def has_account(name, class_name:, auto_create: true, dependent: :restrict_with_error)
        has_one(name, -> { where(name: name) },
                as: :owner, class_name: class_name, # rubocop:disable Rails/ReflectionClassName
                dependent: dependent, inverse_of: :owner)

        after_create(:"create_#{name}", if: -> { send(name).nil? }) if auto_create
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
