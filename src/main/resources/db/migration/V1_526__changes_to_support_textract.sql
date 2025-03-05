alter table flow.attachment add column if not exists processed boolean default false;

insert into flow.key_pattern (key_pattern, archived)
select 'new-utility-bills/%s', false
where not exists (
  select 1
  from flow.key_pattern
  where key_pattern = 'new-utility-bills/%s'
);

create table if not exists flow.attachment_type_secondary_key_pattern
(
  attachment_type_id            integer,
  secondary_key_pattern_id      integer,
  archived                      boolean default false,
  PRIMARY KEY (attachment_type_id, secondary_key_pattern_id),
  FOREIGN KEY (attachment_type_id) REFERENCES flow.attachment_type (id),
  FOREIGN KEY (secondary_key_pattern_id) REFERENCES flow.key_pattern (id)
);

create index if not exists idx_secondary_attachment_type_key
  on flow.attachment_type_secondary_key_pattern (attachment_type_id);
create index if not exists idx_secondary_key_pattern_secondary
  on flow.attachment_type_secondary_key_pattern (secondary_key_pattern_id);

insert into flow.attachment_type_secondary_key_pattern (attachment_type_id, secondary_key_pattern_id, archived)
values ((select id from flow.attachment_type where attachment_type = 'Utility Bill' and company_id = 3  limit 1),
        (select id from flow.key_pattern where key_pattern = 'new-utility-bills/%s' limit 1),
        false)
on conflict (attachment_type_id, secondary_key_pattern_id) do nothing;
