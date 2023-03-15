DROP FUNCTION IF EXISTS brs.get_residual_account_details(date);
create table if not exists brs.residual_plan_status
(
  id          bigint not null
    constraint residual_plan_status_pk
      primary key,
  status_type varchar(20) not null
);


create table if not exists brs.residual_plan
(
  id          bigserial
    constraint residual_plan_pk
      primary key,
  name        text,
  total       numeric(10, 2) default 0 not null,
  residual_plan_status_id   bigint     not null     default 1
    constraint residual_plan_residual_plan_status_id_fk
      references brs.residual_plan_status,
  approved_date    timestamp with time zone,
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint residual_plan_created_by_user_id_fk
      references flow."user",
  approved_by_id bigint
    constraint residual_plan_approved_by_user_id_fk
      references flow."user",
  parent_id   bigint
    constraint residual_plan_residual_plan_id_fk
      references brs.residual_plan,
  description text,
  notes       text,
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    references flow."user"
);

create index if not exists residual_plan_name_trgm_idx
  on brs.residual_plan (name);

create index if not exists residual_plan_approved_by_idx
  on brs.residual_plan (approved_by_id);

create index if not exists residual_plan_parent_id_idx
  on brs.residual_plan (parent_id);

create index if not exists residual_plan_status_id_idx
  on brs.residual_plan (residual_plan_status_id);


create table if not exists brs.residual_plan_allocation
(
  id                 bigserial
    constraint residual_plan_allocation_pk
      primary key,
  residual_plan_id bigint not null
    constraint residual_plan_allocation_plan_id_fk
      references brs.residual_plan,
  allocation         integer not null,
  min                integer not null,
  max                integer,
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint residual_plan_allocation_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint residual_plan_allocation_modified_by_id_fk
    references flow."user"
);

create index if not exists  residual_plan_allocation_residual_plan_id_idx
  on brs.residual_plan_allocation (residual_plan_id);


create table if not exists brs.residual_plan_partial_allocation
(
  id                 bigserial
    constraint residual_plan_partial_allocation_pk
      primary key,
  residual_plan_allocation_id bigint not null
    constraint residual_plan_partial_allocation_plan_id_fk
      references brs.residual_plan_allocation,
  fdc_count                         integer not null,
  partial_allocation                numeric(10, 2) not null,
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint residual_plan_partial_allocation_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint residual_plan_partial_allocation_modified_by_id_fk
      references flow."user"
);

create index if not exists residual_plan_partial_allocation_idx
  on brs.residual_plan_partial_allocation (residual_plan_allocation_id);


create table if not exists  brs.residual_plan_user
(
  id                 bigserial
    constraint residual_plan_user_pk
      primary key,
  residual_plan_id bigint                                 not null
    constraint residual_plan_user_residual_plan_id_fk
      references brs.residual_plan,
  user_id            bigint                                 not null
    constraint residual_plan_user_user_id_fk
      references flow."user",
  start_date         date                                   not null,
  end_date           date,
  note               text,
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint residual_plan_user_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint residual_plan_user_modified_by_id_fk
      references flow."user"
);


create index if not exists residual_plan_user_residual_plan_id_idx
  on brs.residual_plan_user (residual_plan_id);

create index if not exists residual_plan_user_user_id_date_range_excl
  on brs.residual_plan_user (user_id, daterange(start_date, end_date, '[]'::text));

create unique index if not exists residual_plan_user_user_id_residual_plan_id_udx
  on brs.residual_plan_user (user_id, residual_plan_id);

create unique index if not exists residual_plan_user_end_date_is_null_udx
  on brs.residual_plan_user (user_id) where end_date is null;


create table if not exists brs.residual
(
  id                   bigserial
    constraint residual_pk
      primary key,
  period_end           date,
  paid_date            date,
  description          text,
  payroll_status_id    bigint   default 1     not null
    constraint residual_payroll_status_id_fk
      references brs.payroll_status,
  current              boolean  default false not null,
  selected_user_ids bigint[] default '{}'::bigint[],
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint residual_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint residual_modified_by_id_fk
      references flow."user"
);


create index if not exists residual_payroll_status_id_idx
  on brs.residual (payroll_status_id);

insert into brs.residual(period_end, paid_date, description, date_created, created_by_id, date_modified, modified_by_id)
(select '2023-02-25','2023-02-25','initial',now(),2350555,now(),2350555
 where not exists (select id from brs.residual as r where r.period_end = '2023-02-25'));


create table  if not exists brs.residual_adjustment
(
  id                         bigserial
    constraint residual_adjustment_pk
      primary key,
  residual_id                 bigint not null
    constraint residual_adjustment_residual_id_fk
      references brs.residual
      on delete cascade,
  user_id                 bigint not null
    constraint residual_adjustment_user_id_fk
      references flow.user
      on delete cascade,
  amount                     numeric(10, 2),
  note                       text,
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint residual_adjustment_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint residual_adjustment_modified_by_id_fk
      references flow."user",
  payroll_adjustment_type_id bigint not null
    constraint residual_payroll_adjustment_type_id_fk
      references brs.payroll_adjustment_type
);


create index if not exists residual_adjustment_payroll_adjustment_type_id_idx
  on brs.residual_adjustment (payroll_adjustment_type_id);

create index if not exists residual_adjustment_user_id_idx
  on brs.residual_adjustment (user_id);


create index if not exists residual_adjustment_residual_id_idx
  on brs.residual_adjustment (residual_id);

insert into brs.payroll_adjustment_type(id,adjustment_type)
(select 3,'RESIDUALS'
 where not exists (select id from brs.payroll_adjustment_type as pat
                   where pat.adjustment_type = 'RESIDUALS'));



create table if not exists brs.user_residual_snapshot
(
  id                          bigserial
    constraint user_residual_snapshot_pk
      primary key,
  residual_id                  bigint not null
    constraint user_residual_snapshot_residual_id_fk
      references brs.residual,
  user_id                  bigint not null
    constraint user_residual_snapshot_user_id_fk
      references flow.user,
  user_first_name             text,
  user_last_name              text,
  employee_id                 text,
  region_name                 text,
  office_name                 text,
  office_state                text,
  user_position_name          text,
  user_status                 text,
  hire_date                   date,
  user_full_name              text,
  residual_start_date         date,
  residual_plan_name          text,
  lifetime_qualified_fds      integer,
  qualified_fdc_in_period     integer,
  fdc_not_qualified_in_period integer,
  required_fdc_per_month      integer,
  residual_earned             boolean,
  percent_of_residual_earned  numeric,
  potential_residual          numeric,
  earned_residual             numeric,
  clawback                    numeric,
  adjustment_override         numeric,
  residual_total              numeric,
  paid_in_period              boolean not null default false,
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint user_residual_snapshot_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint user_residual_snapshot_modified_by_id_fk
      references flow."user"
);



create index if not exists project_commission_snapshot_payroll_id_idx
  on brs.user_residual_snapshot (residual_id);

create unique index if not exists user_residual_snapshot_user_id_payroll_id_udx
  on brs.user_residual_snapshot (user_id, residual_id);


create table if not exists brs.user_residual_project_snapshot_type
(
  id          bigserial not null
    constraint user_residual_project_snapshot_type_pk
      primary key,
  user_residual_project_snapshot_type varchar(50) not null,
    user_residual_project_snapshot_code varchar(50) not null
);

create index if not exists user_residual_project_snapshot_type_code_idx
  on brs.user_residual_project_snapshot_type (user_residual_project_snapshot_code);


insert into brs.user_residual_project_snapshot_type(user_residual_project_snapshot_type, user_residual_project_snapshot_code)
(select 'Lifetime Qualified FDS','LIFETIME_QUALIFIED_FDS'
 where not exists (select id from brs.user_residual_project_snapshot_type where user_residual_project_snapshot_code = 'LIFETIME_QUALIFIED_FDS'));

insert into brs.user_residual_project_snapshot_type(user_residual_project_snapshot_type, user_residual_project_snapshot_code)
  (select 'FDS Qualified this Period','FDS_QUALIFIED_THIS_PERIOD'
   where not exists (select id from brs.user_residual_project_snapshot_type where user_residual_project_snapshot_code = 'FDS_QUALIFIED_THIS_PERIOD'));

insert into brs.user_residual_project_snapshot_type(user_residual_project_snapshot_type, user_residual_project_snapshot_code)
  (select 'FDS not Qualified this Period','FDS_NOT_QUALIFIED_THIS_PERIOD'
   where not exists (select id from brs.user_residual_project_snapshot_type where user_residual_project_snapshot_code = 'FDS_NOT_QUALIFIED_THIS_PERIOD'));

insert into brs.user_residual_project_snapshot_type(user_residual_project_snapshot_type, user_residual_project_snapshot_code)
  (select 'Clawbacks','CLAWBACKS'
   where not exists (select id from brs.user_residual_project_snapshot_type where user_residual_project_snapshot_code = 'CLAWBACKS'));


create table if not exists brs.user_residual_project_snapshot
(
  id                                          bigserial
    constraint user_user_residual_project_snapshot_pk
      primary key,
  user_residual_snapshot_id                   bigint
    constraint user_residual_project_snapshot_user_id_fk
      references brs.user_residual_snapshot
      on delete cascade,
  project_id                                  bigint
    constraint user_residual_project_snapshot_project_id_fk
      references flow.project,
  user_residual_project_snapshot_type_id        bigint
    constraint urps_user_residual_project_snapshot_type_id_dk
    references brs.user_residual_project_snapshot_type,
  final_design_complete_date                  date,
  final_design_signed_date                    date,
  utility_bill_verified_date                  date,
  financial_agreement_signed_date             date,
  proof_of_homeowners_insurance_required      bigint,
  proof_of_homeowners_insurance_obtained_date date,
  project_state_id                            integer,
  total_cash_down_payment                     numeric,
  first_cash_payment_amount                   numeric,
  substantial_completion_date                 date,
  cancelled_date                              date,
  on_hold_date                                date,
  qualified_date                              date,
  total                                       numeric(10, 2),
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint user_residual_project_snapshot_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint user_residual_project_snapshot_modified_by_id_fk
      references flow."user"
);

create unique index if not exists  user_residual_project_snapshot_mt_udx
  on brs.user_residual_project_snapshot (user_residual_snapshot_id, project_id,user_residual_project_snapshot_type_id);

create index if not exists urps_user_residual_snapshot_id_idx
  on brs.user_residual_project_snapshot (user_residual_snapshot_id);

create index if not exists urps_project_id_idx
  on brs.user_residual_project_snapshot (project_id);



create table if not exists brs.user_residual
(
  id               bigserial
    constraint user_residual_pk
      primary key,
  user_id       bigint not null
    constraint ur_user_id_fk
      references flow.user,
  residual_plan_id bigint not null
    constraint pr_user_residual_plan_id_id_fk
      references brs.residual_plan,
  constraint pr_comp_uk
    unique (residual_plan_id, user_id),
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint user_residual_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint user_residual_modified_by_id_fk
      references flow."user"
);


create index if not exists user_residual_user_id_idx
  on brs.user_residual (user_id);

create index if not exists user_residual_residual_plan_id_idx
  on brs.user_residual (residual_plan_id);


insert into brs.ledger_type(id,ledger_type)
(select 6,'RESIDUAL_CLAWBACK'
 where not exists(select id from brs.ledger_type as lt where lt.id = 6));

create table if not exists brs.residual_ledger
(
  id             bigserial
    constraint residual_ledger_pk
      primary key,
  project_id     bigint
    constraint residual_ledger_project_id_fk
      references flow.project,
  user_id        bigint
    constraint residual_ledger_user_id_fk
      references flow.user,
  ledger_type_id bigint
    constraint residual_ledger_ledger_type_id_fk
      references brs.ledger_type,
  amount         numeric(10, 2) default 0,
  note           text,
  residual_id     bigint not null
    constraint residual_ledger_residual_id_fk
      references brs.residual
      on delete cascade,
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint residual_ledger_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint residual_ledger_modified_by_id_fk
      references flow."user",
  residual_clawback_paid boolean not null default false
);


create index if not exists residual_ledger_ledger_type_id_idx
  on brs.residual_ledger (ledger_type_id);

create index if not exists  residual_ledger_project_id_idx
  on brs.residual_ledger (project_id);

create index if not exists residual_ledger_residual_id_idx
  on brs.residual_ledger (residual_id);

create index if not exists residual_ledger_user_id_idx
  on brs.residual_ledger (user_id);



create table if not exists brs.residual_project_override_qualified_date
(
  id               bigserial
    constraint residual_project_override_qualified_date_pk
      primary key,
  project_id       bigint not null
    constraint residual_project_override_qualified_date_project_id_fk
      references flow.project,
  override_qualified_date date,
  constraint pr_comp_uk1
    unique (project_id),
  date_created              timestamp with time zone not null,
  date_modified              timestamp with time zone not null,
  created_by_id           bigint
    constraint residual_project_override_qualified_date_created_by_fk
      references flow."user",
  modified_by_id           bigint
    constraint residual_project_override_qualified_date_updated_by_fk
    references flow."user"
);

create index if not exists residual_project_override_qualified_date_project_id_idx
  on brs.residual_project_override_qualified_date (project_id);




create table if not exists brs.residual_project_qualified_date
(
  id               bigserial
    constraint residual_project_qualified_date_pk
      primary key,
  project_id       bigint not null
    constraint residual_project_qualified_date_project_id_fk
      references flow.project,
  qualified_date date,
  constraint pr_comp_uk2
    unique (project_id),
  date_created              timestamp with time zone not null,
  date_modified              timestamp with time zone not null,
  created_by_id           bigint
    constraint residual_project_qualified_date_created_by_fk
      references flow."user",
  modified_by_id           bigint
    constraint residual_project_qualified_date_updated_by_fk
      references flow."user"
);

create index if not exists qualified_project_residual_project_id_idx
  on brs.residual_project_qualified_date (project_id);


create table if not exists brs.residual_clawback
(
  id               bigserial
    constraint residual_clawback_pk
      primary key,
  user_id       bigint not null
    constraint rc_user_id_fk
      references flow.user,
  constraint rc_comp_uk
    unique (user_id),
  clawback_due numeric not null default 0,
  applied_clawback numeric not null default 0,
  date_created     timestamp with time zone not null,
  created_by_id  bigint not null
    constraint rc_created_by_user_id_fk
      references flow."user",
  date_modified     timestamp not null,
  modified_by_id  bigint not null
    constraint rc_modified_by_id_fk
      references flow."user"
);


create index if not exists rc_user_id_idx
  on brs.residual_clawback (user_id);

alter table brs.residual_project_qualified_date
  add column  if not exists  residual_id bigint;


alter table brs.residual_project_qualified_date
  drop constraint  if exists residual_project_qualified_date_residual_id_fk;
alter table brs.residual_project_qualified_date
  add constraint residual_project_qualified_date_residual_id_fk
    FOREIGN KEY (residual_id)
      references brs.residual
        MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;



alter table brs.user_residual_project_snapshot
drop column if exists project_state_id;

alter table brs.user_residual_project_snapshot
add column  if not exists state varchar;

alter table brs.residual_project_qualified_date add column  if not exists excluded_from_cancel boolean not null default false;

ALTER TABLE brs.residual_project_override_qualified_date ALTER COLUMN date_created SET DEFAULT now();
ALTER TABLE brs.residual_project_override_qualified_date ALTER COLUMN date_modified SET DEFAULT now();

ALTER TABLE brs.residual_adjustment ALTER COLUMN date_created SET DEFAULT now();
ALTER TABLE brs.residual_adjustment ALTER COLUMN date_modified SET DEFAULT now();

-- insert into brs.residual_plan(name, total, residual_plan_status_id, approved_date, date_created, created_by_id, approved_by_id, parent_id, description, notes, date_modified, modified_by_id)
-- values('Legacy',100.00,2,now(),now(),2354650,2354650,null,'Residual for legacy','Residual for legacy',now(),2354650);
--
-- insert into brs.residual_plan(name, total, residual_plan_status_id, approved_date, date_created, created_by_id, approved_by_id, parent_id, description, notes, date_modified, modified_by_id)
-- values('Enhanced',100.00,2,now(),now(),2354650,2354650,(select id from brs.residual_plan as rp where rp.name = 'Legacy'),'Residual for Enhanced','Residual for Enhanced',now(),2354650);
--
--
-- insert into brs.residual_plan_allocation(residual_plan_id,allocation, min, max,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan as rp where rp.name = 'Legacy'),1,0,10,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_allocation(residual_plan_id,allocation, min, max,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan as rp where rp.name = 'Legacy'),2,11,30,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_allocation(residual_plan_id,allocation, min, max,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan as rp where rp.name = 'Legacy'),3,31,null,now(),now(),2354650,2354650);
--
--
-- insert into brs.residual_plan_allocation(residual_plan_id,allocation, min, max,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan as rp where rp.name = 'Enhanced'),1,0,10,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_allocation(residual_plan_id,allocation, min, max,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan as rp where rp.name = 'Enhanced'),2,11,30,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_allocation(residual_plan_id,allocation, min, max,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan as rp where rp.name = 'Enhanced'),3,31,50,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_allocation(residual_plan_id,allocation, min, max,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan as rp where rp.name = 'Enhanced'),4,51,100,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_allocation(residual_plan_id,allocation, min, max,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan as rp where rp.name = 'Enhanced'),5,101,null,now(),now(),2354650,2354650);
--
-- insert into brs.residual_plan_partial_allocation( residual_plan_allocation_id,fdc_count, partial_allocation,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan_allocation where allocation = 3 and residual_plan_id in (select id from brs.residual_plan as rp where name = 'Enhanced')),2,.40,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_partial_allocation( residual_plan_allocation_id,fdc_count, partial_allocation,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan_allocation where allocation = 4 and residual_plan_id in (select id from brs.residual_plan as rp where name = 'Enhanced')),2,.40,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_partial_allocation( residual_plan_allocation_id,fdc_count, partial_allocation,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan_allocation where allocation = 4 and residual_plan_id in (select id from brs.residual_plan as rp where name = 'Enhanced')),3,.60,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_partial_allocation( residual_plan_allocation_id,fdc_count, partial_allocation,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan_allocation where allocation = 5 and residual_plan_id in (select id from brs.residual_plan as rp where name = 'Enhanced')),2,.40,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_partial_allocation( residual_plan_allocation_id,fdc_count, partial_allocation,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan_allocation where allocation = 5 and residual_plan_id in (select id from brs.residual_plan as rp where name = 'Enhanced')),3,.50,now(),now(),2354650,2354650);
-- insert into brs.residual_plan_partial_allocation( residual_plan_allocation_id,fdc_count, partial_allocation,date_created,date_modified,modified_by_id,created_by_id)
-- values((select id from brs.residual_plan_allocation where allocation = 5 and residual_plan_id in (select id from brs.residual_plan as rp where name = 'Enhanced')),4,.60,now(),now(),2354650,2354650);


-- insert into brs.residual_plan_user(residual_plan_id, user_id, start_date, end_date, note, date_created, created_by_id, date_modified, modified_by_id)
--   (select distinct (select id from brs.residual_plan as rp where rp.name = 'Legacy'),u.id,tru.start_date,
--                    case when ucfv1.date_value is not null then case when ucfv1.date_value < tru.start_date::date then tru.start_date::date + 1 else ucfv1.date_value end
--                         when ucfv1.date_value is not null then  ucfv1.date_value else null end,'Legacy',now(),2354650,now(),2354650
--    from flow.user u
--           inner join flow.user_custom_field_value ucfv  on u.id = ucfv.user_id and ucfv.custom_field_group_assignment_id = 19176
--           inner join brs.temp_residuals_users tru on tru.employee_id = ucfv.text_value and tru.employee_id is not null
--           left join flow.user_custom_field_value ucfv1  on u.id = ucfv1.user_id and ucfv1.custom_field_group_assignment_id = 306
--           left join flow.user_custom_field_value ucfv2  on u.id = ucfv2.user_id and ucfv2.custom_field_group_assignment_id = 331);


-- insert into brs.residual_plan_user(residual_plan_id, user_id, start_date, end_date, note, date_modified,modified_by_id,date_created,created_by_id)
--   (with users as (
--     select distinct up.user_id
--     from flow.user_position up
--            inner join flow.position p on p.id = up.position_id and p.id = 1
--     except
--     select user_id
--     from brs.residual_plan_user rpu)
--    select (select id from brs.residual_plan as rp where rp.name = 'Enhanced'),u.id,
--           coalesce(coalesce(ucfv2.date_value,(select min(start_date) from flow.user_position as up2 where up2.user_id = u.id and up2.position_id =1)),'1901-01-01'),
--           coalesce(ucfv1.date_value,(select min(up2.end_date) from flow.user_position as up2 where up2.user_id = u.id and up2.position_id =1)),
--           'Enhanced',now(),2354650,now(),2354650
--    from flow.user u
--           inner join users use on use.user_id = u.id
--           left join flow.user_custom_field_value ucfv1  on u.id = ucfv1.user_id and ucfv1.custom_field_group_assignment_id = 306
--           left join flow.user_custom_field_value ucfv2  on u.id = ucfv2.user_id and ucfv2.custom_field_group_assignment_id = 331
--    where u.id not in (2371700,2373010,2375300,2436057,2441438,2451659,2452116,2353600,2400520,2407061,2400164,2393486,2444569,2352650,2448001));
--
-- insert into brs.user_residual(user_id, residual_plan_id,created_by_id,date_created,modified_by_id,date_modified)
--   (select user_id,rpu.residual_plan_id,2354650,now(),2354650,now()
--    from brs.residual_plan_user as rpu);




