# frozen_string_literal: true

module Generalis
  class Link < ActiveRecord::Base
    belongs_to :entry, inverse_of: :links
    belongs_to :linkable, polymorphic: true

    validates :name, presence: true
  end
end
