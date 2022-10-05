ALTER TABLE brs.custom_field_group_assignment
  add column if not exists hidden bool default false;
ALTER TABLE brs.custom_field_group_assignment
  add column if not exists read_only bool default false;

CREATE TABLE IF NOT EXISTS brs.white_listed_position
(
  id                               bigserial primary key   not null,
  custom_field_group_assignment_id bigint                  not null
    references brs.custom_field_group_assignment (id) on update restrict on delete restrict,
  position_id                      bigint                  not null
    references flow.position (id) on update restrict on delete restrict,
  created_by_id                    bigint                  not null
    references flow."user" (id),
  date_created                     timestamp default now(),
  modified_by_id                   bigint
    references flow."user" (id),
  date_modified                    timestamp default now(),
  white_list_type_id               bigint                  not null
    references flow.white_list_type (id),
  archived                         boolean   default false not null
);

create unique index if not exists brs_wlp_ux on brs.white_listed_position (custom_field_group_assignment_id, position_id, white_list_type_id) where (archived is false);
CREATE INDEX IF NOT EXISTS brs_wlp_cfga_id_ix on brs.white_listed_position (custom_field_group_assignment_id);
CREATE INDEX IF NOT EXISTS brs_wlp_position_id_ix on brs.white_listed_position (position_id);
CREATE INDEX IF NOT EXISTS brs_wlp_white_list_type_id_ix on brs.white_listed_position (white_list_type_id);
