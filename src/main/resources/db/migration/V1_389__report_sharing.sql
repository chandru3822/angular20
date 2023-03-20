create table if not exists flow.smartlist_access_control
(
  id               bigserial,
  smartlist_id     bigint not null
    constraint sac_smartlist_id___fk
      references flow.smartlist,
  org_id           bigint
    constraint sac_org_id___fk
      references flow.org,
  user_position_id bigint
    constraint sac_user_position_id___fk
      references flow.user_position,
  access_control_id bigint not null
    constraint sac_access_control_id__fk
      references flow.access_control,
  date_created     timestamp not null default now(),
  date_modified    timestamp default now(),
  created_by_id    bigint not null
    constraint sac_created_by_id__fk
      references flow."user",
  modified_by_id                  bigint
    constraint sac_modified_by_id__fk
      references flow."user",
  archived         boolean default false not null
);

create index if not exists sac_org_id_idx on flow.smartlist_access_control (org_id);

create index if not exists sac_smartlist_id_idx on flow.smartlist_access_control (smartlist_id);

create index if not exists sac_user_position_id_idx on flow.smartlist_access_control (user_position_id);