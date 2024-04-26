create table if not exists brs.residual_plan_partial_allocation_type
(
  id                 bigserial
    constraint residual_plan_partial_allocation_type_pk
      primary key,
  residual_plan_partial_allocation_type text,
  rank_order integer,
  archived boolean not null default false
);

alter table brs.residual_plan_partial_allocation add column if not exists
  residual_plan_partial_allocation_type_id bigint;

create index if not exists residual_plan_partial_allocation_id_idx
  on brs.residual_plan_partial_allocation (residual_plan_partial_allocation_type_id);

alter table brs.residual_plan add column if not exists
  is_based_on_source boolean default false;

alter table brs.residual_plan_partial_allocation drop constraint if exists rpsa_residual_plan_partial_allocation_type_id_fk;
alter table brs.residual_plan_partial_allocation
  add CONSTRAINT rpsa_residual_plan_partial_allocation_type_id_fk FOREIGN KEY (residual_plan_partial_allocation_type_id)
    REFERENCES brs.residual_plan_partial_allocation (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;


insert into brs.residual_plan_partial_allocation_type(residual_plan_partial_allocation_type, rank_order)
  (select 'Total System Size',1
   where not exists (select id from brs.residual_plan_partial_allocation_type as rpa
                               where rpa.residual_plan_partial_allocation_type = 'Total System Size'));

insert into brs.residual_plan_partial_allocation_type(residual_plan_partial_allocation_type, rank_order)
  (select 'System Size by Closer Gen Sources',2
   where not  exists (select id from brs.residual_plan_partial_allocation_type as rpa
                         where rpa.residual_plan_partial_allocation_type = 'System Size by Closer Gen Sources'));



alter table brs.user_residual_project_snapshot
  add column  if not exists system_size_by_source numeric;

update brs.residual_plan_partial_allocation rppa
set residual_plan_partial_allocation_type_id = (select id from brs.residual_plan_partial_allocation_type
                                                         where residual_plan_partial_allocation_type = 'Total System Size');

alter table brs.residual_plan_partial_allocation alter column residual_plan_partial_allocation_type_id set not null;

