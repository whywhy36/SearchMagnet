require 'yaml'
require 'logger'
require_relative '../db_helper'

require 'pry'

class SourceConfig
  @@instance = nil

  def self.get_instance
    @@instance = YAML.load_file("#{File.dirname(__FILE__)}/config/database.yml") unless @@instance
    @@instance
  end
end

module OldSource
  class Torrent < ActiveRecord::Base
    postgres_config = SourceConfig.get_instance['source']
    establish_connection(
        adapter: 'postgresql',
        host: postgres_config['host'],
        database: postgres_config['database'],
        username: postgres_config['username'],
        password: postgres_config['password'],
        encoding: postgres_config['encoding']
    )
  end
end

module SearchMagnet
  module Feeds
    class DataMigrator
      def initialize
        config = SourceConfig.get_instance

        name           = config['name']
        @source_config = config['source']
        logging_config = config['logging']

        @logger = Logger.new("#{logging_config['output']}#{name}.log")
        @logger.level = Logger.const_get(logging_config['level']) || Logger::INFO
      end

      def run(&callback)
        binding.pry
        OldSource::Torrent.all.each do |torrent|
          target_torrent = Torrent.where('data_hash' => torrent.data_hash)
          if target_torrent.size == 0
            target_torrent = Torrent.create(
                :name       => torrent.name,
                :data_hash  => torrent.data_hash,
                :length     => torrent.length,
                :category   => torrent.category,
                :magnet_uri => torrent.magnet_uri,
                :metadata   => torrent.metadata,
                :counter    => torrent.counter,
                :created_at => torrent.create_at,
                :updated_at => torrent.updated_at
            )
            callback.call(target_torrent) if callback
          else
            # do nothing
            @logger.info "Torrent with same datahash #{torrent.data_hash} exists in target database."
          end
        end
      end
    end
  end
end

SearchMagnet::Feeds::DataMigrator.new.run do |torrent|
  puts "updated torrent [#{torrent.id}] #{torrent.name}"
end
puts 'Done!'