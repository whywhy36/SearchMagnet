class InitDatabase < ActiveRecord::Migration
  def change
    create_table :torrents do |t|
      t.string :name,         :null => false
      t.string :files
      t.string :data_hash,    :null => false
      t.string :length
      t.string :category
      t.string :magnet_uri,   :null => false
      t.string :metadata,     :null => false
      t.integer :counter
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
      t.string :source
      t.boolean :blocked
    end
  end
end
