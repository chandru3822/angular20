update brs.residual_plan_partial_allocation_type
  set residual_plan_partial_allocation_type = 'Self Gen System Size'
where residual_plan_partial_allocation_type = 'System Size by Closer Gen Sources';

insert into brs.residual_plan_partial_allocation_type(residual_plan_partial_allocation_type)
  (select 'Total FDC Count'
   where not  exists (select id from brs.residual_plan_partial_allocation_type as rpa
                      where rpa.residual_plan_partial_allocation_type = 'Total FDC Count'));

alter table brs.residual_plan_partial_allocation_type
drop column if exists rank_order;

create table if not exists brs.commission_strategy_type
(
  id                 bigserial
    constraint commission_strategy_type_pk
      primary key,
  commission_strategy_type text,
  archived boolean not null default false
);

insert into brs.commission_strategy_type(commission_strategy_type, archived)
(select 'High Commissions',false
 where not exists (select id from brs.commission_strategy_type as cst
                             where cst.commission_strategy_type = 'High Commissions'));

insert into brs.commission_strategy_type(commission_strategy_type, archived)
  (select 'Residual',false
   where not exists (select id from brs.commission_strategy_type as cst
                     where cst.commission_strategy_type = 'Residual'));


alter table brs.commission_plan add column if not exists
  commission_strategy_type_id bigint;

alter table brs.commission_plan drop constraint if exists rp_commission_strategy_type_id_fk;
alter table brs.commission_plan
  add CONSTRAINT rp_commission_strategy_type_id_fk FOREIGN KEY (commission_strategy_type_id)
    REFERENCES brs.commission_strategy_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION;

create index if not exists commission_plan_commission_strategy_type_id_idx
  on brs.commission_plan (commission_strategy_type_id);

update brs.commission_plan cp
set commission_strategy_type_id = (select id from brs.commission_strategy_type
                                             where commission_strategy_type = 'High Commissions')
where cp.id = 63;

update brs.commission_plan rp
set commission_strategy_type_id = (select id from brs.commission_strategy_type
                                   where commission_strategy_type = 'Residual')
where rp.id != 63;


update brs.residual_plan_partial_allocation rppa
set residual_plan_partial_allocation_type_id = (select id from brs.residual_plan_partial_allocation_type
                                                where residual_plan_partial_allocation_type = 'Total FDC Count')
where residual_plan_allocation_id in (select id from brs.residual_plan_allocation rpa
                                                where rpa.residual_plan_id in (1,2));

update brs.residual_plan rp
set residual_duration_months = 120
where id in (1,2);


alter table brs.user_residual_snapshot
add column  if not exists lifetime_system_size numeric;

alter table brs.user_residual_snapshot
  add column  if not exists qualified_this_period_system_size numeric;
