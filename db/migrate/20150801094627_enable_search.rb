class EnableSearch < ActiveRecord::Migration
  def up
    execute 'alter table torrents add column tsv tsvector;'
    execute 'create index tsv_index on torrents using gin(tsv);'
    execute "update torrents set tsv = to_tsvector(coalesce(name, ''));"
    execute p %{
create function torrents_search_trigger() RETURNS trigger AS $$
	begin
		new.tsv := to_tsvector(coalesce(new.name, ''));
		return new;
	end
$$ LANGUAGE plpgsql;
    }
    execute 'create trigger tsvectorupdate before insert or update on torrents for each row execute procedure torrents_search_trigger();'
  end

  def down
    execute 'drop trigger if exists tsvectorupdate on torrents;'
    execute 'drop function if exists torrents_search_trigger();'
    execute 'drop index tsv_index'
    remove_column :torrents, :tsv
  end
end
