# frozen_string_literal: true

# Company Cash account.
Generalis::Asset.define(:cash)

# Ordering Revenue accounts.
Generalis::Revenue.define(:orders)
Generalis::Revenue.define(:delivery_fees)
Generalis::Revenue.define(:platform_fees)
