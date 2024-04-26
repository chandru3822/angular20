create table if not exists brs.residual_plan_source_allocation
(
  id                 bigserial
    constraint resiudal_plan_source_allocation_pk
      primary key,
  residual_plan_id bigint not null
    constraint residual_plan_source_allocation_id_fk
      references brs.residual_plan,
  source_id          bigint not null
    constraint rpsa_source_id_fk
      references flow.list_of_value,
  amount numeric not null,
  archived boolean not null default false
);


create index residual_plan_source_allocation_residual_plan_id_idx
  on brs.residual_plan_source_allocation (residual_plan_id);

create index residual_plan_source_allocation_source_idx
  on brs.residual_plan_source_allocation (source_id);


alter table brs.residual_plan add column if not exists residual_duration_months bigint;
alter table brs.residual_plan add column if not exists is_system_size boolean not null default false;


ALTER TABLE brs.user_residual_snapshot
  ALTER COLUMN required_fdc_per_month TYPE numeric;

ALTER TABLE brs.user_residual_snapshot
  ALTER COLUMN qualified_fdc_in_period TYPE numeric;



alter table brs.user_residual_project_snapshot
add column  if not exists system_size numeric;

alter table brs.user_residual_project_snapshot
  add column  if not exists residual_plan text;

alter table brs.user_residual_project_snapshot
  add column  if not exists system_size_adjusted_for_source numeric;




insert into brs.residual_plan(name, total, residual_plan_status_id, approved_date, date_created, created_by_id, approved_by_id, parent_id,
                              description, notes, date_modified, modified_by_id,
                              default_plan, residual_duration_months, is_system_size)
  (select 'Legacy System Size',14,2,approved_date, date_created, created_by_id, approved_by_id,1,'This is a legacy plan for System Size',
          'Legacy System Size plan', date_modified, modified_by_id,
          false,60,true
   from brs.residual_plan as rp
   where rp.id = 1);

insert into brs.residual_plan(name, total, residual_plan_status_id, approved_date, date_created, created_by_id, approved_by_id, parent_id,
                              description, notes, date_modified, modified_by_id,
                              default_plan, residual_duration_months, is_system_size)
  (select 'Enhanced System Size',14,2,approved_date, date_created, created_by_id, approved_by_id,2,'This is a Enhanced plan for System Size',
          'Enhanced System Size plan', date_modified, modified_by_id,
          false,48,true
   from brs.residual_plan as rp
   where rp.id = 2);

insert into brs.residual_plan_allocation(residual_plan_id, allocation, min, max, date_created, created_by_id, date_modified, modified_by_id)
values(3,20,0,null,now(),2384850,now(),2384850);

insert into brs.residual_plan_allocation(residual_plan_id, allocation, min, max, date_created, created_by_id, date_modified, modified_by_id)
values(4,20,0,null,now(),2384850,now(),2384850);

insert into brs.residual_plan_source_allocation(residual_plan_id, source_id, amount, archived)
values (3,523,1.15,false);
insert into brs.residual_plan_source_allocation(residual_plan_id, source_id, amount, archived)
values (3,530,1.15,false);
insert into brs.residual_plan_source_allocation(residual_plan_id, source_id, amount, archived)
values (3,524,1.15,false);
insert into brs.residual_plan_source_allocation(residual_plan_id, source_id, amount, archived)
values (3,20016,1.15,false);

insert into brs.residual_plan_source_allocation(residual_plan_id, source_id, amount, archived)
values (4,523,1.15,false);
insert into brs.residual_plan_source_allocation(residual_plan_id, source_id, amount, archived)
values (4,530,1.15,false);
insert into brs.residual_plan_source_allocation(residual_plan_id, source_id, amount, archived)
values (4,524,1.15,false);
insert into brs.residual_plan_source_allocation(residual_plan_id, source_id, amount, archived)
values (4,20016,1.15,false);




