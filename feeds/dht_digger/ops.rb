require 'redis'
require 'yaml'
require 'json'
require 'logger'
require_relative '../db_helper'

require 'pry'

module SearchMagnet
  module Feeds
    class DHTDigger

      def initialize
        @config = YAML.load_file("#{File.dirname(__FILE__)}/config/database.yml")

        @name           = @config['name']
        @source         = @config['source']
        redis_config    = @config['redis']
        logging_config  = @config['logging']

        @redis = Redis.new(:host => redis_config['host'],
                           :port => redis_config['port'],
                           :db   => redis_config['db'])

        @parsed_torrent_metadata_queue = redis_config['metadata']

        @logger = Logger.new("#{logging_config['output']}#{@name}.log")
        @logger.level = Logger.const_get(logging_config['level']) || Logger::INFO
      end

      def run(&callback)
        loop do
          item_string = @redis.blpop(@parsed_torrent_metadata_queue)[1]
          @logger.info "item_string is #{item_string}"
          next if item_string.nil? or item_string.eql? 'null'
          item = JSON.parse(item_string)

          category = classify_item(item)
          name = item['name']
          data_hash = item['data_hash']
          length = item['length']
          create_time = item['create_time']
          files = item['files']
          magnet_uri = item['magnet_uri'] || ''

          target_torrent = Torrent.where('data_hash' => data_hash)
          torrent = nil
          if target_torrent.size == 1
            Torrent.increment_counter(:counter, target_torrent.id)
            torrent = target_torrent
          elsif target_torrent.size == 0
            torrent = Torrent.create(
                :name       => name,
                :data_hash  => data_hash,
                :length     => length,
                :category   => category,
                :magnet_uri => magnet_uri,
                :metadata   => item_string,
                :counter    => 1,
                :created_at => create_time,
                :updated_at => DateTime.now,
                :source     => @source
            )
          else
            # should not be here
            @logger.warn "unexpected event: #{target_torrent.size} torrents with same data_hash #{data_hash}"
          end
          callback.call(torrent) if callback and torrent
        end
      end

      def classify_item(item)

      end
    end
  end
end

SearchMagnet::Feeds::DHTDigger.new.run do |torrent|
  puts "created or updated torrent with id #{torrent.id}"
end
