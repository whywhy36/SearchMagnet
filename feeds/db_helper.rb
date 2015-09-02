require 'yaml'
require 'active_record'
require 'pg'

config = YAML.load_file "#{File.dirname(__FILE__)}/postgres.yml"
postgres_config = config['postgres']

ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    host: postgres_config['host'],
    database: postgres_config['database'],
    username: postgres_config['username'],
    password: postgres_config['password'],
    encoding: postgres_config['encoding']
)

require_relative '../app/models/torrent'
