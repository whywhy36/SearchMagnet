require 'pg_search'

class Torrent < ActiveRecord::Base
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

