# frozen_string_literal: true

# == Schema Information
#
# Table name: links
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
#  index_links_on_entry_id           (entry_id)
#  index_links_on_entry_id_and_name  (entry_id,name)
#  index_links_on_linkable           (linkable_type,linkable_id)
#
# Foreign Keys
#
#  fk_rails_...  (entry_id => entries.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :link, class: 'Generalis::Link' do
    association :entry, strategy: :build
    association :linkable, factory: :account, strategy: :build

    name { 'test' }
  end
end
