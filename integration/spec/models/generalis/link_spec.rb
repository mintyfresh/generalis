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
require 'rails_helper'

RSpec.describe Generalis::Link, type: :model do
  subject(:link) { build(:link) }

  it 'has a valid factory' do
    expect(link).to be_valid
  end

  it 'is invalid without an entry' do
    link.entry = nil
    expect(link).to be_invalid
  end

  it 'is invalid without an linkable' do
    link.linkable = nil
    expect(link).to be_invalid
  end

  it 'is invalid without a name' do
    link.name = nil
    expect(link).to be_invalid
  end
end
