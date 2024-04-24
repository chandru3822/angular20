create table if not exists flow.import_sp_project
(
  id                 bigserial
    constraint import_sp_project_pk
      primary key,
  project_id      bigint                  not null
    constraint isp_project_id_fk
      references flow.project,
  sp_project_id text not null,
  sp_project_data jsonb not null,
  file_name text not null,
  date_created timestamp not null default now()
);

create index if not exists isp_project_id_idx
  on flow.import_sp_project (project_id);

create index if not exists isp_sp_project_id_idx
  on flow.import_sp_project (sp_project_id);
