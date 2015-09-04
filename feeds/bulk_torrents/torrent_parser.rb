require 'date'

module SearchMagnet
  module Feeds
    module TorrentHelper

      # parse torrent meta to one friendly hash
      def parse_torrent(meta)
        info = {}

        # created_at
        info['created_at'] = meta.has_key?('creation date') ?
            Time.at(meta['creation date']).to_datetime :
            DateTime.now

        # some general keys
        %w(announce comment publisher publisher-url created\ by).each do |key|
          info[key] = meta[key].force_encoding('UTF-8') if meta.has_key? key
        end

        # detailed info in meta_info
        meta_info = meta['info'] || meta

        if meta_info.has_key? 'files'
          info['files'] = meta_info['files'].map do |file_info|
            path = (file_info.has_key?('path.utf-8') ? file_info['path.utf-8'] : file_info['path']).join('/').force_encoding('UTF-8')
            {
                'path'   => path,
                'length' => file_info['length']
            }
          end

          info['length'] = info['files'].inject(0) { |ret, file| ret + file['length'] }
        else
          # only one file and there must be one 'length' key
          info['length'] = meta_info['length']
        end

        info['data_hash'] = Digest::MD5.hexdigest(meta_info['pieces'])
        info['name'] = meta_info['name'].to_s

        # calculate info_hash (to construct magnet link)
        info_hash = Digest::SHA1.hexdigest(meta['info'].bencode)
        info['magnet_uri'] = "magnet:?xt=urn:btih:#{info_hash}"

        info
      end
    end
  end
end