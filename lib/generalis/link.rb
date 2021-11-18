# frozen_string_literal: true

# == Schema Information
#
# Table name: ledger_links
#
#  id            :bigint           not null, primary key
#  entry_id      :bigint           not null
#  linkable_type :string           not null
#  linkable_id   :bigint           not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_ledger_links_on_entry_id           (entry_id)
#  index_ledger_links_on_entry_id_and_name  (entry_id,name)
#  index_ledger_links_on_linkable           (linkable_type,linkable_id)
#
# Foreign Keys
#
#  fk_rails_...  (entry_id => ledger_entries.id) ON DELETE => cascade
#
module Generalis
  class Link < ActiveRecord::Base
    belongs_to :entry, inverse_of: :links
    belongs_to :linkable, polymorphic: true

    validates :name, presence: true
  end
end
