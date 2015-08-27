require_relative '../models/torrent'

class SearchController < ApplicationController
  def index
    @torrent = Torrent.first
    keyword = 'nirvana'
    @result_torrent = Torrent.search(keyword)
  end
end
