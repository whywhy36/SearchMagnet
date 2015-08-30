require 'pg_search'
require 'json'
require 'friendly_id'
require 'filesize'

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

  def file_descriptions(compact=true)
    files = JSON.parse(self.metadata)['files'] || []
    files = files.size > 4 ? files[0, 5] : files if compact

    ret = files.map do |item|
      {
          :path => item['path'],
          :size => Filesize.from("#{item['length']} B").pretty
      }
    end
  end

  def pretty_size
    length = JSON.parse(self.metadata)['length']
    Filesize.from("#{length} B").pretty
  end

  def file_number
    files = JSON.parse(self.metadata)['files']
    return 1 if files.nil? or files.empty?
    files.size
  end
end


