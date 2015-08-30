require_relative '../models/torrent'

class SearchController < ApplicationController
  def index

  end

  def result
    @keyword = params[:keyword]
    @results = Torrent.search(@keyword).paginate(:page => params[:page], :per_page => 10)
  end

  def details
    @torrent = Torrent.friendly.find(params[:id])
  end
end
