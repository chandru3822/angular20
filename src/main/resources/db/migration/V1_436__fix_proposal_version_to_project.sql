drop table if exists brs.proposal_project_proposal_version;
create table if not exists brs.proposal_project_proposal_version
(
  project_id          bigint not null references flow.project (id),
  proposal_version_id bigint not null references brs.proposal_version (id),
  date_created        timestamptz default now(),
  date_modified       timestamptz default now(),
  created_by_id       bigint,
  modified_by_id      bigint,

  constraint proposal_project_id_pk
    primary key (project_id)
);

create index pppv_proposal_version_id_idx
  on brs.proposal_project_proposal_version (proposal_version_id);


--migrate existing data for consistency
with migrate as (select distinct on (pps.project_id) pps.project_id,
                                                     p.proposal_version_id,
                                                     p.created_by_id,
                                                     p.date_created
                 from brs.proposal p
                        inner join flow.project_process_step pps on p.project_process_step_id = pps.id
                        inner join flow.project pr on pps.project_id = pr.id
                 where pr.archived is false
                   and pps.archived is false
                   and p.archived is false
                 order by pps.project_id, p.proposal_version_id desc)
insert
into brs.proposal_project_proposal_version (project_id, proposal_version_id,
                                            created_by_id, date_created,
                                            modified_by_id, date_modified)
select m.project_id, m.proposal_version_id, m.created_by_id, m.date_created, m.created_by_id, m.date_created
from migrate m
order by m.date_created
on conflict (project_id) do nothing;
