alter table if exists flow.contact
add if not exists temp_geo_attempted boolean default false not null;