create table if not exists flow.smartlist_metrics
(
  id                     bigserial
    constraint smartlist_metrics_pk
      primary key,
  smartlist_id           bigint                  not null
    constraint smartlist_metrics_smartlist_id__fk
      references flow.smartlist,
  smartlist              jsonb                   not null,
  smartlist_fields       jsonb                   not null,
  smartlist_requirements jsonb                   not null,
  query                  text                    not null,
  execution_duration     bigint                  not null,
  created_by_id          bigint                  not null
    constraint smartlist_metrics_created_by_id__fk
      references flow."user",
  date_created           timestamp default now() not null
);

create index if not exists smartlist_metrics_created_by_id_idx on flow.smartlist_metrics (created_by_id);

create index if not exists smartlist_metrics_smartlist_id_idx on flow.smartlist_metrics (smartlist_id);