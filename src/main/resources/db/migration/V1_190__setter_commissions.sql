alter table brs.project_commission_ledger rename column closer_id  to user_id;
alter table brs.project_commission_ledger add column if not exists position_id integer;
update brs.project_commission_ledger
set position_id = 1;


drop index if exists  brs.pcl_position_id_idx;
create index pcl_position_id_idx
    on brs.project_commission_ledger (position_id);

drop index if exists  brs.cp_position_id_idx;
create index cp_position_id_idx
    on brs.commission_plan (position_id);

drop index if exists  brs.op_position_id_idx;
create index op_position_id_idx
    on brs.override_plan (position_id);




drop FUNCTION if exists brs.get_total_overrides(  integer, bigint[], integer);
drop FUNCTION if exists brs.get_ledger_totals( integer,  bigint[], integer);

alter table brs.payroll_adjustment rename column closer_id to user_id;


alter table brs.payroll add column if not exists position_id integer;

drop index if exists  brs.payroll_position_id_idx;
create index payroll_position_id_idx
    on brs.payroll (position_id);

update brs.payroll set position_id = 1;


drop FUNCTION if exists brs.create_payroll(
 INTEGER
);


alter table brs.project_details add column if not exists setter_milestone_pay timestamp;

drop index if exists  brs.pd_setter_milestone_pay_idx;
create index pd_setter_milestone_pay_idx
    on brs.project_details (setter_milestone_pay);

with update_data as (
select least(first_appointment_pitched,first_appointment_missed) as updated_date,project_id
from brs.project_details
group by project_id,first_appointment_pitched,first_appointment_missed)
update brs.project_details pd
set setter_milestone_pay = updated_date
from update_data ud
where ud.project_id = pd.project_id;


update flow.feature
set feature_path = '/commissionManagement/users'
where id = 13;


select * from  brs.create_payroll(
        2350555,
   4
);


create table if not exists brs.setter_project_commission_snapshot
(
    id                          serial  not null
        constraint setter_project_commission_snapshot_pk
        primary key,
    payroll_id                  integer not null
        constraint setter_project_commission_snapshot_id_fk
            references brs.payroll,
    project_id                  integer not null
        constraint setter_project_commission_snapshot_project_id_fk
            references flow.project,
    project_name               varchar(200),
    sales_rep_id                integer,
    sales_rep                   varchar(200),
    source                      varchar(200),
    cancelled                   date,
    closer_appointment_start    timestamp,
    closer_appointment_outcome  varchar,
    override_plan               varchar(200),
    override_plan_id            integer,
    commission_plan_id          integer,
    commission_plan             varchar(200),
    total_commissions           numeric(10, 2),
    total_overrides             numeric(10, 2),
    commissions_earned          numeric(10, 2),
    override_earned             numeric(10, 2),
    commission_adjustment       numeric(10, 2),
    override_adjustment         numeric(10, 2),
    commission_paid_to_date     numeric(10, 2),
    overrides_paid_to_date      numeric(10, 2),
    current_pay                 numeric(10, 2),
    current_pay_commissions     numeric(10, 2),
    current_pay_overrides       numeric(10, 2),
    remaining_value             numeric(10, 2),
    remaining_value_commissions numeric(10, 2),
    remaining_value_overrides   numeric(10, 2),
    project_total_value         numeric(10, 2),
    updated                     timestamp with time zone
);

drop index if exists brs.setter_project_commission_snapshot_project_id_payroll_id_udx;
create unique index setter_project_commission_snapshot_project_id_payroll_id_udx
    on brs.setter_project_commission_snapshot (project_id, payroll_id);



create table if not exists brs.setter_project_override_commission_snapshot
(
    id                             serial not null
        constraint setter_project_override_commission_snapshot_pk
        primary key,
    setter_project_commission_snapshot_id integer
        constraint setter_project_override_commission_snapshot_id_fk
            references brs.setter_project_commission_snapshot
            on delete cascade,
    user_id                        integer
        constraint setter_project_override_commission_snapshot_user_id_fk
            references flow."user",
    milestone_type_id              integer
        constraint setter_project_override_commission_snapshot_milestone_id_fk
            references brs.milestone_type,
    total                          numeric(10, 2)
);

drop index if exists brs.setter_project_commission_snapshot_id_user_id_milestone_id_udx;
create unique index setter_project_commission_snapshot_id_user_id_milestone_id_udx
    on brs.setter_project_override_commission_snapshot (setter_project_commission_snapshot_id, user_id, milestone_type_id);


drop function if exists brs.get_commission_summary();
