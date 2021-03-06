# Generalis

Generalis is a financial general ledger for ActiveRecord.
It incorporates a light DSL for defining ledger transactions and connecting financial records to your existing models, built-in currency support, and RSpec integrations.

If DSLs are not to your liking, Generalis also provides support for [ad-hoc transactions](#ad-hoc-transactions) that behave more like plain-old ActiveRecord models.

Generalis currently only supports and is tested against PostgreSQL, but support for other database systems is planned.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'generalis'
```

And then execute:

    $ bundle install

To generate the classes and configuration used by Generalis, run:

    $ bin/rails generate generalis:install

To generate the migration files for the supporting database tables, run:

    $ bin/rails generate generalis:migrations

And then run:

    $ bin/rails db:migrate

### MoneyRails Integration

Generalis relies on MoneyRails to operate and handle currencies correctly. It's not necessary to add it to your Gemfile directly, however, it is necessary to generate the configuration initializer:

https://github.com/RubyMoney/money-rails#installation

## Ledger Accounts

Generalis includes 4 of the most common major account types:

| Account Type | Balance Behaviour |
| ------------ | ----------------- |
| Asset        | Debit Normal      |
| Expense      | Debit Normal      |
| Liability    | Credit Normal     |
| Revenue      | Credit Normal     |

These account types can be accessed as follows:
 - `Generalis::Asset`
 - `Generalis::Expense`
 - `Generalis::Liability`
 - `Generalis::Revenue`

Additional account types can be defined if necessary. (See the section on [custom account types](#custom-account-types).)

Ledger accounts can be either global or associated to a particular record. The differences between the to mechanisms is explained in detail below.

### Global Accounts

Global ledger accounts are typically those that are associated with your own business.
For example, your company's own cash, revenue, and expenses would typically be global accounts in Generalis.

For accounts which pertain to a particular client or customer (like owed balance or store credits), see the section on [Associated Accounts](#associated-accounts).

#### Defining Global Accounts

Global accounts can be created with the `define(...)` helper, which will automatically create the account if it doesn't already exist:

```ruby
Generalis::Asset.define(:cash)
```

Global accounts are unique based on their name, so only one global account (of any type) can exist with a given name.
It's typical practice to define your global accounts ahead of time, as a seed.

#### Retrieving Global Accounts

Global accounts can be retrieved by their name using either `[]` index notation or by using the `.lookup()` helper method:

```ruby
cash = Generalis::Asset[:cash]

# OR

cash = Generalis::Asset.lookup(:cash)
```

Both methods above will raise an `ActiveRecord::RecordNotFound` error if the requested account does not exist.

Generalis accounts are just plain-old ActiveRecord objects, so it's also possible to use all the normal query methods like `.where(...)` and `.find_by(...)`.

### Associated Accounts

Associated ledger accounts are used to represent balances that belong to a particular client, customer, or some other record in your system. For example, a balance owed by a particular customer or a store credit issued to a customer would be modeled by an associated account.

When using associated accounts, multiple ledger account records may share the same name, but will be uniquely distinguished by their `owner` association.
The balances each of these owner records is therefore tracked separately.

#### Defining Associated Accounts

Generalis provides an `Accountable` concern that should be included into your application's ActiveRecord models to automatically associate ledger accounts.

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

It's also possible to access the account using the same helpers methods as global accounts, by specifying the owner record:

```ruby
customer = Customer.create!(...)

Generalis::Asset[:accounts_receivable, owner: customer] # => #<Generalis::Asset:0x0000... >
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

By default, associated accounts are treated as `dependent: :restrict_with_error`. This means that trying to delete a record with associated accounts will be prevented and ActiveModel::Errors will be set.

This behaviour can be changed using:

```ruby
  has_asset_account :accounts_receivable, dependent: :destroy
```

NOTE: Accounts with associated ledger entries cannot be deleted as doing so would interfere with the state of the ledger. One possible option to circumvent this limitation would be to leave an orphaned record for the account.

This can be done with:

```ruby
  has_asset_account :accounts_receivable, dependent: false
```

### Balances and Currency Support

Generalis has first-class support for currency built-in, however, it doesn't perform any automatic exchange or normalization.

Instead, each currency is stored as a separate balance on the account, for example:

```ruby
cash = Generalis::Asset[:cash]

cash.balance('CAD') # => #<Money $100.00>
cash.balance('USD') # => #<Money $0.00>
cash.balance('EUR') # => #<Money ???25.00>
```

Requesting the balance of a currency that does not appear on an account will return 0 (as a Money object).

It's also possible to request a summary of all balances on an account:

```ruby
cash.balances # => {"CAD"=>#<Money $100.00>,"EUR"=>#<Money ???25.00>}
```

### Custom Account Types

Generalis allows additional account types to be defined if necessary. For example, if you wished to define an equity account type, you would add the following model to your application:

```ruby
class Equity < Generalis::Account
  balance_type :credit_normal
end
```

The `balance_type` macro defines the behaviour of the balance when credited or debited an amount. The supported modes are:
  - `:debit_normal` (like Asset or Expense accounts)
  - `:credit_normal` (like Liability or Revenue accounts)

Alternatively, if you'd prefer to keep naming consistent with the built-in account types, you can instead define your account in an initializer:

```ruby
module Generalis
  class Equity < Account
    balance_type :credit_normal
  end
end
```

## Ledger Transactions

Ledger transactions are a record of an event or action in the system that impacted the ledger. They are made up of a collection of ledger entries which occurred together.

Writing to the ledger is accomplished by creating a Transaction record, with the associated credit and debit entries applying changes to the balances of their corresponding accounts.

For a Transaction to be valid, the credit and debit entries included in the transaction must balance. This means that the sum of all credits must equal the sum of all debits (per currency).
This is a best-effort constraint is enforced by a validation on the transaction model, as well as by marking key attributes on persisted ledger entries as read-only.
Generalis is not able to prevent validations from being disabled or removed, nor existing data from being modified directly in the database. For more information, see the [data integrity](#data-integrity) section.

Transactions also store additional information to describe the changes made to the ledger:

| Field          | Type          | Usage |
| -------------- | ------------- | ----- |
| type           | String        | An optional field used for Rails' Single-Table Inheritance functionality. |
| transaction_id | String        | A unique key for the transaction, intended to prevent duplicate operations, typically human-readable. |
| description    | String        | An optional message describing the event or action that caused this transaction. |
| occurred_at    | Time          | An optional timestamp indicating when the event or action occurred that trigger this transaction. |
| metadata       | Hash or Array | An optional JSON field used to store application-specific information. Can be used with [`store_accessor`](https://api.rubyonrails.org/classes/ActiveRecord/Store.html) to define custom attributes. |

**NOTE:** In most cases, `metadata` should not be used to store relationships to other records. Instead, the [linked records](#linked-records) mechanism should be used.

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

The `transaction_id`, `description`, `occurred_at`, and `metadata` DSL macros are used to automatically set their corresponding fields on the constructed Transaction. The functions of these fields is described in the table [here](#ledger-transactions).

Transactions behave like ActiveRecord models, so they can be built and saved as you would any other model in your application:

```ruby
transaction = Ledger::ExampleTransaction.new

if transaction.save
  # All good!
else
  puts transaction.errors
end
```

**NOTE:** Beware of potential naming collisions between `transaction` and some built-in ActiveRecord methods. If creating a `belongs_to` or `has_one` association to a Transaction, you will need to name the association `ledger_transaction` or similar to avoid overwriting the built-in methods.

#### Linked Records

Generalis allows ActiveRecord models to be associated with transaction classes:

```ruby
class Ledger::ExampleTransaction < Ledger::BaseTransaction
  has_one_linked :charge
end
```

Linked records are managed through a polymorphic join-table (handled by the `Generalis::Link` model), so any model can be associated to a transaction without requiring a database migration.

Linked records behave like a standard Rails association, and can be assigned as normal:

```ruby
transaction = Ledger::ExampleTransaction.new
transaction.charge = Charge.find(...)

# OR

charge = Charge.find(...)
transaction = Ledger::ExampleTransaction.new(charge: charge)
```

In cases where the name of the association does not match the name of the class, it's possible to specify the class name explicitly:

```ruby
  has_one_linked :charge, class_name: 'Card::Charge'
```

Has-many style associations are also supported in the same way:

```ruby
  has_many_linked :fees
```

To add inverse associations to your link records, include the `Linkable` concern:

```ruby
class Charge < ApplicationRecord
  include Generalis::Linkable
end
```

This will add an association that allows access to any linked transactions:

```ruby
charge = Charge.find(...)

charge.linked_ledger_transactions # => [ ... ]
```

#### Double-Entry Notation

When using the default double-entry notation, a debit and credit entry are defined together with a shared amount. These two entries are also linked together by a common key (called a `pair_id`) so that they be retrieved together.

If you are already using MoneyRails and store amounts as Money objects, these can be assigned directly to the constructed entries:

```ruby
double_entry do |e|
  e.debit  = Generalis::Asset[:cash]
  e.credit = customer.accounts_receivable
  e.amount = charge.amount
end
```

If your application does not use Money objects, the amount and currency must be specified explicitly. This is done by assigning values to the `amount` and `currency` fields on the entry builder:

```ruby
  e.amount   = 100.00
  e.currency = 'CAD'
```

If your application stores money as an integer number of cents, the `amount_cents` field can be assigned instead:

```ruby
  e.amount_cents = 100_00
  e.currency     = 'CAD'
```

Regardless of which mechanism is used, Generalis internally will store these amounts as Money objects.

#### Manual Credit/Debit Notation

Generalis also provides an alternative to the double-entry notation where credit and debit entries may be separately defined in the DSL:

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

When using this notation, debit and credit entries will not be linked together as a pair (although you can still manually assign a `pair_id`). However, the credited and debited amounts (per currency) must still be equal.

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

This operation would be considered valid, as both the sum of credits and debits equal to $100.00.

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

## Data Integrity

Generalis includes several mechanisms that are intended to ensure correctness and integrity of the ledger state and balances. These include validations on the Transaction model, attributes being marked read-only on the ledger Entry model, and automatic locking for ledger Accounts included in a Transaction.

However, it should be noted that these are all best-effort mechanisms and they are not able to catch or prevent all efforts to tamper with the data.
Validations can be disabled or removed, read-only constraints can be ignored by queries made directly in the database.

For this reason, a number of tools are provided to assist with prevent and catching these issues if they occur.

### Verifying Balances

The most important point of integrity that Generalis is concerned with is ensuring that the ledger balances. This is traditionally verified using the Balance Sheet Equation, which often takes the form of something like:

```
Assets + Expenses = Liabilities + Revenues + Equity
```

Generalis generalizes this formula to the following constraint:

```
SUM(Debit-Normal Accounts) - SUM(Credit-Normal Accounts) = 0
```

This condition can then be verified with the `trial_balances` helper method:

```ruby
Generalis.trial_balances # => {"CAD"=>0,"USD"=>0,"EUR"=>0}
```

Provided that the balance for each currency sums to zero, the ledger balances for that currency. Any non-zero value indicates that the is error in the ledger.

### Locating Problematic Transactions

If a balance issue has been identified, it's important to locate which transactions are causing the issue. Generalis provides a scope to locate any transactions which do not themselves balance:

```ruby
Generalis::Transaction.imbalanced # => [...]
```

### Accounts and Locking

Generalis automatically handles locking accounts involved in a transaction for the purposes of calculating their balances after the transaction.
However, it is important to note that these locks are acquired _after_ the ledger entries have been prepared by the DSL.

This means that if the balances of the accounts are used as part of the `amount` of the ledger entry, there is a potential race condition with other transactions that may modify the balance of that account.

As an example, consider this transaction which exchanges a customer's store credit from CAD to USD:

```ruby
class Ledger::ExchangeStoreCreditTransaction < Ledger::BaseTransaction
  # ...

  double_entry do |e|
    e.debit  = Generalis::Asset[:cash]
    e.credit = customer.store_credit
    e.amount = customer.store_credit.balance('CAD')
  end

  double_entry do |e|
    e.debit  = customer.store_credit
    e.credit = Generalis::Asset[:cash]
    e.amount = customer.store_credit.balance('CAD').exchange_to('USD')
  end
end
```

It is possible for another transaction to have modified the balance of the `store_credit` account between when the transaction was prepared and when the locks would be acquired to calculate its final balances.

One approach to mitigate this is to acquire locks on the involved accounts ahead of time using a `before_prepare` hook and the `lock_for_account_balance` helper method:

```ruby
  before_prepare do
    Generalis::Account.lock_for_account_balance(
      customer.store_credit,
      Generalis::Asset[:cash]
    )
  end
```

**NOTE:** To avoid the risk of deadlocks between transactions, it is important to include _all_ accounts involved in a transaction when acquiring locks.

## RSpec Matchers

Generalis includes a number of RSpec matchers to help with testing ledger transactions. To use them, add this to your `rails_helper.rb` file:

```ruby
require 'generalis/rspec'
```

### Credit/Debit Account Matchers

When testing transactions, it may be helpful to verify that a particular amount has been credited or debited towards a particular account. For this purpose, the `credit_account` and `debit_account` matchers:

```ruby
let(:charge) { create(:charge) }
let(:customer) { charge.customer }

it 'credits the charge amount to the cash account' do
  expect(transaction).to credit_account(:cash).with_amount(charge.amount)
end

it "debits the charge amount to the customer's receivable account" do
  expect(transaction).to debit_account(customer.accounts_receivable).with_amount(charge.amount)
end
```

Accounts may be specified either by a name (for global accounts) or by an instance of the account object.
The amount may be specified by a Money object or by a numeric value and a currency:

```ruby
  expect(transaction).to credit_account(:cash).with_amount(100.00, 'CAD')
```

These matchers are currency aware, and will only consider the currency that is specified in the amount.

**NOTE:** These matchers will sum together all credits or debits that were made towards the same account. It is not necessary for the transaction to be persisted to use this matcher.

### Change Balance of Account Matcher

When testing transactions, it may also be useful to set expectations of what the net-change to an account balance will be after any credits or debits have been applied towards the account. To do so, the `change_balance_of` matcher is provided:

```ruby
it 'increases the balance of the cash account by the charge amount' do
  expect(transaction).to change_balance_of(:cash).by(charge.amount)
end

it 'does not change the balance of the orders revenue account' do
  expect(transaction).not_to change_balance_of(:orders)
end
```

Accounts may be specified either by a name (for global accounts) or by an instance of the account object.
The amount may be specified by a Money object or by a numeric value and a currency:

```ruby
  expect(transaction).to change_balance_of(:cash).by(100.00, 'CAD')
```

This matcher  currency aware, and will only consider the currency that is specified in the amount.

### Have Balance Matcher

For testing integration between parts of the system and verifying financial flows, the `have_balance` matcher is recommended.

```ruby
let(:order) { create(:order) }
let(:customer) { order.customer }

it "adds the total of the order to the customer's receivable balance after checkout" do
  order.checkout!
  expect(customer.accounts_receivable).to have_balance(order.total)
end
```

Unlike the `debit_account` and `credit_account` matchers which validate a transaction, the `have_balance` matcher tests the balance of a ledger account.

### Examples

Examples of the included RSpec matches being used can be found in the integration test-suite directory, [here](./integration/spec/models/ledger).

## Future Features and Wishlist

Generalis can be better! There's features and helpful tools that we want to build in the future but haven't gotten around to yet. Some of them are:

 - [ ] Better install process for MoneyRails
 - [ ] More documentation for ledger Entry records
 - [ ] Transaction revert and error correction tools
 - [ ] Rails::Engine for a pluggable API

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mintyfresh/generalis.
