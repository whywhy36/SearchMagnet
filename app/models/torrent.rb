require 'pg_search'
require 'friendly_id'

class Torrent < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  include PgSearch
  pg_search_scope(
      :search,
      against: %i(
        name
      ),
      using: {
          tsearch: {
              dictionary: "english",
          }
      }
  )
end

