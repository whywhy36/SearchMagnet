require 'yaml'
require 'logger'
require 'bencode'
require 'digest'
require 'json'
require_relative '../db_helper'
require_relative 'torrent_parser'

require 'pry'

module SearchMagnet
  module Feeds
    class BulkTorrentsImporter
      include TorrentHelper

      def initialize
        @config = YAML.load_file("#{File.dirname(__FILE__)}/config/torrents.yml")

        @name           = @config['name']
        @source         = @config['source']
        logging_config  = @config['logging']
        @path           = @config['torrents_source']['path']
        @path << '/' unless @path.end_with?('/')

        @logger = Logger.new("#{logging_config['output']}#{@name}.log")
        @logger.level = Logger.const_get(logging_config['level']) || Logger::INFO

        @torrent_counter = 0
      end

      def run(&callback)
        @logger.info "Start parsing all torrents in #{@path}."
        Dir["#{@path}**/*.torrent"].each do |torrent_file|
          begin
            process_torrent(torrent_file, &callback)
          rescue => ex
            @logger.error "Could not parse torrent: #{ex.inspect}"
          end
        end
        @logger.info "Parsed #{@torrent_counter} torrents."
      end

      def process_torrent(path, &callback)
        puts "Parsing torrent file #{path}"
        meta = BEncode.load_file(path) # File or file path

        torrent = parse_torrent(meta)

        binding.pry

        target_torrent = Torrent.where('data_hash' => torrent['data_hash'])

        if target_torrent.size == 0
          torrent_object = Torrent.create(
              :name       => torrent['name'].to_s,
              :data_hash  => torrent['data_hash'],
              :length     => torrent['length'],
              :metadata   => torrent.to_json,
              :magnet_uri => '',
              :counter    => 1,
              :created_at => torrent['created_at'],
              :updated_at => DateTime.now,
              :source     => @source
          )

          callback.call(torrent_object) if callback
        end

        @torrent_counter += 1
      end
    end
  end
end

SearchMagnet::Feeds::BulkTorrentsImporter.new.run