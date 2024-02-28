create table if not exists flow.sms_cache
(
  id               bigserial,
  project_id       bigint
    constraint sms_cache_project_id_fk
      references flow.project,
  user_id          bigint
    constraint sms_cache_user_id_fk
      references flow.user,
  message_text     text    not null,
  outbound_message boolean not null default false,
  message_date     timestamp        default now(),
  created_by_id    bigint
    constraint sms_cache_created_by_id_fk
      references flow.user,
  date_created     timestamp        default now() not null,
  modified_by_id   bigint
    constraint sms_cache_modified_by_id_fk
      references flow.user,
  date_modified    timestamp        default now()
);

create unique index if not exists sms_cache_project_id_idx
  on flow.sms_cache (project_id);

create unique index if not exists sms_cache_user_id_idx
  on flow.sms_cache (user_id);

alter table flow.sms_cache
  drop constraint if exists check_only_one_null_constraint_sms_cache;
alter table flow.sms_cache
  add CONSTRAINT check_only_one_null_constraint_sms_cache CHECK (
    (user_id IS NOT NULL AND project_id IS NULL) OR
    (user_id IS NULL AND project_id IS NOT NULL) OR
    (user_id IS NOT NULL AND project_id IS NOT NULL)
    );


alter table flow."user"
  add column if not exists user_full_name_search varchar
    generated always as (
      (lower(translate((COALESCE(first_name, '')), '*,.& ', '')) || ' ') ||
      lower(translate((COALESCE(last_name, '')), '*,.& ', ''))
      ) stored;

create index if not exists user_full_name_search_idx
  on flow.user using gin (user_full_name_search public.gin_trgm_ops);

create index if not exists pdetails_building_permit_number_idx
  on brs.project_details using gin ((trim(lower(translate(building_permit_number, E'/()_.,-:\n\r\t ', ''))))
                                    gin_trgm_ops);

create index if not exists pdetails_electrical_permit_number_idx
  on brs.project_details using gin ((trim(lower(translate(electrical_permit_number, E'/()_.,-:\n\r\t ', ''))))
                                    gin_trgm_ops);

create index if not exists pdetails_mpu_permit_number_idx
  on brs.project_details using gin ((trim(lower(translate(mpu_permit_number, E'/()_.,-:\n\r\t ', '')))) gin_trgm_ops);
