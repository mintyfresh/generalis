# Generalis

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/generalis`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'generalis'
```

And then execute:

    $ bundle install

To generate the classes and configuration used by generalis, run:

    $ bin/rails generate generalis:install

To generate the migration files for the supporting database tables, run:

    $ bin/rails generate generalis:migrations

And then run:

    $ bin/rails db:migrate

## Usage

TODO: Write usage instructions here

## Ledger Accounts

### Global Accounts

### Associated Accounts

Generalis providers an `Accountable` concern that can be included into your application's models to automatically associate ledger accounts.

For example, to create an Asset account called "accounts_receivable" for a customer model, use:

```ruby
class Customer < ApplicationRecord
  include Generalis::Accountable

  has_asset_account :accounts_receivable
end
```

DSL macros are available for all four types of supported accounts:

```ruby
  has_asset_account :name
  has_expense_account :name
  has_liability_account :name
  has_revenue_account :name
```

The associated account can then be accessed just like any standard association:

```ruby
customer = Customer.create!(...)

customer.accounts_receivable # => #<Generalis::Asset:0x0000... >
```

#### Manual Account Creation

By default, associated accounts are created automatically together with the accountable record. It's possible to disable this behaviour using:

```ruby
  has_asset_account :accounts_receivable, auto_create: false
```

The associated account can be created later using a built-in helper:

```ruby
customer = Customer.create!(...)

customer.create_accounts_receivable # => #<Generalis::Asset:0x00000... >
```

To locate records that are missing an associated account, a scope is automatically provided:

```ruby
customers_missing_accounts = Customer.without_accounts_receivable
```

#### Dependent Account Behaviour

By default, associated accounts are treated as 'dependent: :restrict_with_error`. This means that trying to delete a record with associated accounts will be prevented and ActiveModel::Errors will be set.

This behaviour can be changed using:

```ruby
  has_asset_account :accounts_receivable, dependent: :destroy
```

NOTE: Accounts with associated ledger entries cannot be deleted as doing so would interfere with the state of the ledger. One possible option to circumvent this limitation would be to leave an orphaned record for the account.

This can be done with:

```ruby
  has_asset_account :accounts_receivable, dependent: false
```

## Ledger Transactions


### Transaction DSL

To create a transaction model, run the generator:

    $ bin/rails generate generalis:transaction Example

This will generate a new transaction model in your `app/models/ledger` directory, which contains a stub ledger transaction:

```ruby
# frozen_string_literal: true

class Ledger::ExampleTransaction < Ledger::BaseTransaction
  transaction_id do
    # TODO: Generate a transaction ID
  end

  description do
    # Optional: Provide a description of the transaction
  end

  occurred_at do
    # Optional: Include a timestamp for the transaction (defaults to now)
  end

  metadata do
    # Optional: Any additional metadata to be stored with the transaction (an Array or Hash)
  end

  double_entry do |e|
    # TODO: Define entries
    # e.debit  = Generalis::Asset[:cash]
    # e.credit = customer.accounts_receivable
    # e.amount = 100.00
  end
end
```

#### Double-Entry Notation

```ruby
double_entry do |e|
  e.debit  = Generalis::Asset[:cash]
  e.credit = customer.accounts_receivable
  e.amount = 100.00
end
```

If your application does not use Money objects, you can specify amounts and currency explicitly via:

```ruby
  e.amount   = 100.00
  e.currency = 'CAD'
```

Or if your application works with money as integers, it can be assigned directly as a value in cents:

```ruby
  e.amount_cents = 100_00
  e.currency     = 'CAD'
```

Internally, generalis stores money using Money objects.

#### Manual Credit/Debit Notation

```ruby
credit do |e|
  e.account = Generalis::Asset[:cash]
  e.amount  = 100.00
end

debit do |e|
  e.account = customer.accounts_receivable
  e.amount  = 100.00
end
```

When using this notation, debit and credit entries will not be linked together as a pair. However, the credited and debited amounts (per currency) must still be equal.

This notation also allows for transactions that have non-equal numbers of credits and debits, provided that their total amounts sum up to be equal. For example:

```ruby
credit do |e|
  e.account = Generalis::Asset[:cash]
  e.amount  = 90.00
end

credit do |e|
  e.account = Generalis::Asset[:holding]
  e.amount  = 10.00
end

debit do |e|
  e.account = accounts.accounts_receivable
  e.amount  = 100.00
end
```

Would be allowed, as both the sum of credits and debits equal to $100.00.

### Ad-Hoc Transactions

Generalis also supports creating transactions without using the DSL by directly using the built-in Transaction model. We refer to these as ad-hoc transactions, and they can be useful in cases where there is significant branching in transaction logic, or where defining a transaction class is otherwise not possible.

An example ad-hoc transaction might look like:

```ruby
transaction = Generalis::Transaction.new

transaction.transaction_id = "charge-#{charge.id}"
transaction.description = "Customer #{customer.id} charge for #{charge.amount}"

# Define the credits and debits that are involved in the transaction.
transaction.add_credit(account: Generalis::Asset[:cash], amount: charge.amount)
transaction.add_debit(account: customer.accounts_receivable, amount: charge.amount)

# Add a linked record for future reference.
transaction.add_link(:charge, charge)

transaction.save!
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mintyfresh/generalis.
