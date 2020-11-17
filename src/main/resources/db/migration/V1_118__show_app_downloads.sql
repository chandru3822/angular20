alter table flow.attachment
add column if not exists show boolean not null default false;
