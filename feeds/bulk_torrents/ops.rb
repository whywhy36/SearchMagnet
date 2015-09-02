require 'yaml'
require 'logger'
require 'bencode'
require 'digest'
require_relative '../db_helper'

require 'pry'

module SearchMagnet
  module Feeds
    class BulkTorrentsImporter
      def initialize
        @config = YAML.load_file("#{File.dirname(__FILE__)}/config/torrents.yml")

        @name           = @config['name']
        logging_config  = @config['logging']
        @path           = @config['source']['path']
        @path << '/' unless @path.end_with?('/')

        @logger = Logger.new("#{logging_config['output']}#{@name}.log")
        @logger.level = Logger.const_get(logging_config['level']) || Logger::INFO

        @torrent_counter = 0
      end

      def run(&callback)
        @logger.info "Start parsing all torrents in #{@path}."
        Dir["#{@path}**/*.torrent"].each do |torrent_file|
          parse_torrent(torrent_file, &callback)
        end
        @logger.info "Parsed #{@torrent_counter} torrents."
      end

      def parse_torrent(path, &callback)
        puts "Parsing torrent file #{path}"
        meta = BEncode.load_file(path) # File or file path
        meta_info = Digest::SHA1.hexdigest(meta["info"].bencode)
        puts meta_info.inspect
        @torrent_counter += 1
      end
    end
  end
end

SearchMagnet::Feeds::BulkTorrentsImporter.new.run do |torrent|

end