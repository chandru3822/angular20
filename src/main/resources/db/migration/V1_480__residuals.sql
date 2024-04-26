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

create index if not exists residual_plan_source_allocation_residual_plan_id_idx
  on brs.residual_plan_source_allocation (residual_plan_id);

create index if not exists residual_plan_source_allocation_source_idx
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




