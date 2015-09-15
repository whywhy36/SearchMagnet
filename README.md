# SearchMagnet Website

Yet another BT Search Engine Website. 

### Features
- search
- multiple data source

### Usage
This is a typical Rails application with Postgres as the only supported database. The search feature is based on 
Postgres built-in text search.

For a quick setup for development environment, run following commands:
```
rake db:migrate
rails console
```

### Data Source
To populate the database, we provide some feeders. Each feed can insert some torrents metadata from 
existing data source, like bulk of torrents, existing torrent meatadata datbase and DHT diggers.

#### bulk of torrents
This feeder can parse all .torrent files under specific folder and store the metadata into database.
Folder path can be specified in config/torrent.yml.
```
torrents_source:
  path: [your torrents folder path]
```

#### data migraiton
This feeder may not be used without customizaiton, it aims at migrating torrents metadata in one existing database to the current one.
The old data source can configured in config/database.yml
```
source:
  host: [old database host]
  port: [old database port]
  username: [old database username]
  password: [old database password]
  database: [old database name]
  encoding: utf-8
```

#### dht digger
This feeder consumes the metadata produced by [dht digger](https://github.com/whywhy36/DHTDigger). DHT Digger provide realtime updates about DHT network and torrents information, please refer to 
this [document](http://www.bittorrent.org/beps/bep_0000.html) for more details. 

#### customize your own feede
You can easily import your existing torrents metdata by following the database schema.

### License
MIT
