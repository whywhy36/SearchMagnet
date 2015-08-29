class AddSlugToTorrents < ActiveRecord::Migration
  def change
    add_column :torrents, :slug, :string
    add_index :torrents, :slug
  end
end
