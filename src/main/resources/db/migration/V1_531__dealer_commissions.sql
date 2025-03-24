create table if not exists brs.commission_plan_org
(
  id                 bigserial
    constraint commission_plan_org_pk
      primary key,
  commission_plan_id bigint                                 not null
    constraint commission_plan_org_commission_plan_id_fk
      references brs.commission_plan,
  org_id            bigint                                 not null
    constraint commission_plan_org_user_id_fk
      references flow.org,
  start_date         date                                   not null,
  end_date           date,
  note               text,
  date_modified      timestamp with time zone default now() not null
);



create index if not exists commission_plan_org_commission_plan_id_idx
  on brs.commission_plan_org (commission_plan_id);

create index if not exists commission_plan_org_org_id_id_daterange_excl
  on brs.commission_plan_org (org_id, daterange(start_date, end_date, '[]'::text));

insert into  brs.payroll_adjustment_type(id,adjustment_type)
(select 4,'PARTNER'
 where not exists (select id from brs.payroll_adjustment_type  where adjustment_type = 'PARTNER'));


CREATE TABLE if not exists brs.financial_details_partner (
                                                           id bigserial not null,
                                                           date_created timestamp with time zone DEFAULT now(),
                                                           date_modified timestamp with time zone DEFAULT now(),
                                                           created_by_id integer not null,
                                                           modified_by_id integer,
                                                           archived boolean not null default false,
                                                           partner_commissions_earned_m1 numeric(10,2),
                                                           partner_commissions_earned_m2 numeric(10,2),
                                                           partner_total_commissions numeric(10,2),
                                                           partner_total_commissions_adjustments_paid_to_date numeric(10,2),
                                                           partner_total_commissions_paid_to_date numeric(10,2),
                                                           partner_commission_plan text,
                                                           partner_commission_plan_id bigint,
                                                           partner_commission_plan_status text,
                                                           financial_details_id bigint not null,
                                                           org_id bigint not null,
                                                           position_id bigint not null,
                                                           active boolean not null default false,
                                                           CONSTRAINT brs_financial_details_partner_pk PRIMARY KEY (id),
                                                           CONSTRAINT brs_fdp_created_by_id_fk FOREIGN KEY (created_by_id)
                                                             REFERENCES flow.user (id) MATCH SIMPLE
                                                             ON UPDATE NO ACTION ON DELETE NO ACTION,
                                                           CONSTRAINT brs_fdp_modified_by_id_fk FOREIGN KEY (modified_by_id)
                                                             REFERENCES flow.user (id) MATCH SIMPLE
                                                             ON UPDATE NO ACTION ON DELETE NO ACTION,
                                                           CONSTRAINT brs_fdp_financial_details_id_fk FOREIGN KEY (financial_details_id)
                                                             REFERENCES brs.financial_details (id) MATCH SIMPLE
                                                             ON UPDATE NO ACTION ON DELETE NO ACTION,
                                                           CONSTRAINT brs_fdp_org_id_fk FOREIGN KEY (org_id)
                                                             REFERENCES flow.org (id) MATCH SIMPLE
                                                             ON UPDATE NO ACTION ON DELETE NO ACTION,
                                                           CONSTRAINT brs_fdp_position_id_fk FOREIGN KEY (position_id)
                                                             REFERENCES flow.position (id) MATCH SIMPLE
                                                             ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists fdp_financial_details_id_idx ON brs.financial_details_partner (financial_details_id);
CREATE INDEX if not exists fdp_org_id_idx ON brs.financial_details_partner (org_id);
alter table brs.financial_details_partner drop constraint if exists org_id_financial_details_id_uniq;
ALTER TABLE brs.financial_details_partner
  ADD CONSTRAINT org_id_financial_details_id_uniq UNIQUE (financial_details_id,org_id);


create table if not exists brs.partner_payroll_adjustment
(
  id                         bigserial
    constraint partner_payroll_adjustment_pk
      primary key,
  payroll_id                 bigint not null
    constraint partner_payroll_commission_adjustment_payroll_id_fk
      references brs.payroll
      on delete cascade,
  project_id                 bigint not null
    constraint partner_payroll_commission_adjustment_project_id_fk
      references flow.project
      on delete cascade,
  org_id                    bigint not null
    constraint partner_payroll_commission_adjustment_org_id_fk
      references flow.org,
  amount                     numeric(10, 2),
  note                       text,
  created_by                 bigint
    constraint partner_payroll_commission_adjustment_created_by_fk
      references flow."user",
  created                    timestamp with time zone,
  payroll_adjustment_type_id bigint not null
    constraint partner_payroll_adjustment_payroll_adjustment_type_id_fk
      references brs.payroll_adjustment_type
);


create index if not exists partner_payroll_adjustment_payroll_adjustment_type_id_idx
  on brs.partner_payroll_adjustment (payroll_adjustment_type_id);

create index if not exists partner_payroll_adjustment_org_id_idx
  on brs.partner_payroll_adjustment (org_id);

create index if not exists partner_payroll_adjustment_payroll_id_idx
  on brs.partner_payroll_adjustment (payroll_id);

create index if not exists partner_payroll_adjustment_project_id_idx
  on brs.partner_payroll_adjustment (project_id);


insert into brs.ledger_type(id, ledger_type)
(select 8,'PARTNER_COMMISSION'
 where not exists (select id from brs.ledger_type as lt where lt.ledger_type = 'PARTNER_COMMISSION'));

create table if not exists brs.partner_project_commission_ledger
(
  id             bigserial
    constraint partner_project_commission_ledger_pk
      primary key,
  project_id     bigint
    constraint partner_project_commission_ledger_project_id_fk
      references flow.project,
  org_id        bigint
    constraint partner_project_commission_ledger_org_id_fk
      references flow.org,
  ledger_type_id bigint
    constraint partner_project_commission_ledger_ledger_type_id_fk
      references brs.ledger_type,
  amount         numeric(10, 2) default 0,
  note           text,
  created_by     bigint not null
    constraint partner_project_commission_ledger_created_by_fk
      references flow."user",
  created        timestamp with time zone,
  payroll_id     bigint not null
    constraint partner_project_commission_ledger_payroll_id_fk
      references brs.payroll
      on delete cascade,
  paid_to_date   numeric(10, 2),
  position_id    bigint
    constraint partner_pcl_position_id_fk
      references flow.position
);



create index if not exists dpcl_position_id_idx
  on brs.partner_project_commission_ledger (position_id);

create index if not exists partner_project_commission_ledger_ledger_type_id_idx
  on brs.partner_project_commission_ledger (ledger_type_id);

create index if not exists partner_project_commission_ledger_payroll_id_idx
  on brs.partner_project_commission_ledger (payroll_id);

create index if not exists partner_project_commission_ledger_project_id_idx
  on brs.partner_project_commission_ledger (project_id);

create index if not exists partner_project_commission_ledger_org_id_idx
  on brs.partner_project_commission_ledger (org_id);



alter table brs.project_commission_snapshot add column if not exists partner_org_id bigint;
alter table brs.project_commission_snapshot add column if not exists partner_org_name text;
alter table brs.project_commission_snapshot add column if not exists ahj_final_inspection_verified date;

create table if not exists  brs.partner_project_commission_snapshot
(
  id                                bigserial
    constraint partner_project_commission_snapshot_pk
      primary key,
  payroll_id                        bigint not null
    constraint partner_project_commission_snapshot_payroll_id_fk
      references brs.payroll,
  project_id                        bigint not null
    constraint parnter_project_commission_snapshot_project_id_fk
      references flow.project,
  customer_name                     varchar(200),
  system_size                       numeric(10, 2),
  cancelled                         date,
  commission_plan_id                integer,
  commission_plan                   varchar(200),
  sc                                date,
  commissions_earned                numeric(10, 2),
  commission_paid_to_date           numeric(10, 2),
  remaining_value                   numeric(10, 2),
  current_pay                       numeric(10, 2),
  project_total_value               numeric(10, 2),
  updated                           timestamp with time zone,
  total_commissions                 numeric(10, 2),
  current_pay_commissions           numeric(10, 2),
  remaining_value_commissions       numeric(10, 2),
  partner_org_id                    bigint,
  partner_org_name                  text,
  ahj_final_inspection_verified     date,
  final_design_complete_date        date,
  select_adder_amount               numeric(10, 2),
  custom_adder_amount               numeric(10, 2),
  base_commission                   numeric(10, 2)
);

create index if not exists partner_project_commission_snapshot_payroll_id_idx
  on brs.partner_project_commission_snapshot (payroll_id);

create unique index if not exists partner_project_commission_snapshot_project_id_payroll_id_udx
  on brs.partner_project_commission_snapshot (project_id, payroll_id,partner_org_id);

create index if not exists partner_project_commission_snapshot_partner_org_id_idx
  on brs.partner_project_commission_snapshot (partner_org_id);


alter table brs.partner_project_commission_snapshot add column if not exists position_id bigint;
alter table brs.partner_project_commission_snapshot add column if not exists panel_quantity bigint;


insert into flow.company_configuration_value(company_id, name, code, value, date_created,
                                             date_modified, created_by_id, modified_by_id, archived, readonly)
(select 3,'CFGAs Affecting Partner commissions','CFGA_PARTNER_COMMISSIONS','1251,22722',now(),
       now(),2384850,2384850,false,false
 where not exists (select id from flow.company_configuration_value as ccv where ccv.code = 'CFGA_PARTNER_COMMISSIONS'));

insert into flow.company_configuration_value(company_id, name, code, value, date_created,
                                             date_modified, created_by_id, modified_by_id, archived, readonly)
(select 3,'CFGAs for Partner Org assignment ','CFGA_PARTNER_ORG_ASSIGNMENT','28881,28888',now(),
       now(),2384850,2384850,false,false
 where not exists (select id from flow.company_configuration_value as ccv where ccv.code = 'CFGA_PARTNER_ORG_ASSIGNMENT'));


create table if not exists brs.partner_commission_plan_adder
(
  id                 bigserial
    constraint partner_commission_plan_adder_pk
      primary key,
  commission_plan_id bigint not null
    constraint partner_commission_plan_adder_commission_plan_id_fk
      references brs.commission_plan,
  milestone_id       bigint not null
    constraint partner_commission_plan_adder_milestone_fk
      references brs.milestone_type,
  fee_amount         numeric(10, 2),
  fee_type_id        bigint not null
    constraint partner_commission_plan_adder_fee_type_id_fkey
      references brs.fee_type,
  adder_id          bigint not null
    constraint partner_commission_plan_adder_adder_id_fk
      references flow.list_of_value
);



create index if not exists partner_commission_plan_fee_type_id_idx
  on brs.partner_commission_plan_adder (fee_type_id);

create index if not exists partner_commission_plan_commission_plan_idx
  on brs.partner_commission_plan_adder (commission_plan_id);

create index if not exists partner_commission_plan_milestone_id_idx
  on brs.partner_commission_plan_adder (milestone_id);

create index if not exists partner_commission_plan_adder_id_idx
  on brs.partner_commission_plan_adder (adder_id);


insert into brs.fee_type(id, fee_type)
select 4,'Per Panel'
where not exists (select id from brs.fee_type as ft
                            where ft.fee_type = 'Per Panel');


alter table brs.commission_plan add column if not exists partner_commission_amount numeric;
alter table brs.commission_plan add column if not exists fee_type_id bigint;

alter table brs.commission_plan drop constraint cp_fee_type_id_fk;
alter table brs.commission_plan add CONSTRAINT cp_fee_type_id_fk FOREIGN KEY (fee_type_id)
        REFERENCES brs.fee_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table brs.financial_details_partner add column if not exists active boolean not null default  true;


alter table flow.data_view_field_config add column if not exists parent_cfga_ids bigint[];
alter table flow.data_view_field_config add column if not exists parent_ps_ids bigint[];
alter table flow.data_view_field_config add column if not exists parent_pse_ids bigint[];

alter table brs.financial_details_partner add column  if not exists custom_adder_amount numeric;
alter table brs.financial_details_partner add column  if not exists selected_adder_amount numeric;
alter table brs.financial_details_partner add column  if not exists base_commission_amount numeric;


alter table brs.partner_commission_plan_adder drop column if exists milestone_id;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{27107}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 676;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{31059,31060}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 740;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{31059,31060}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 741;


update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{26166}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 677;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{22491}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 311;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{1}',
    parent_cfga_ids = '{22593}',
    reset_values_on_main = false,
    ignore_if_null =false
where id = 487;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{1}',
    parent_cfga_ids = '{22593}',
    reset_values_on_main = false,
    ignore_if_null =false
where id = 482;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19470}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 151;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19470}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 151;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24894}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 624;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19456,25392}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 203;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19456,25392}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 497;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3620}',
    parent_cfga_ids = '{25400}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 498;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19468,26934}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 152;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24892}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 620;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24893}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 622;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19469}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 177;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19459}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 120;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19453,25388}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 197;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19453,25388}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 493;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19454,25390}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 160;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19454,25390}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 495;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19455,25389}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 161;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19455,25389}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 494;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19465}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 313;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24889}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 612;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19464,25397}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 199;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19464,25397}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 492;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24888}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 610;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19449}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 97;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3392}',
    parent_cfga_ids = '{20864}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 278;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19460}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 171;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19466}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 198;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24890}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 614;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{21714}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 139;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{22036}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 684;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24874}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 606;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24875}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 608;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{22037,33051}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 685;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{22037,33051}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 736;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19451,25391}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 135;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19451,25391}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 678;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19451,25391}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 496;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355,3620}',
    parent_cfga_ids = '{19451,25391}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 679;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19461}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 189;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{22032}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 738;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19467}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 190;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24891}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 618;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19462}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 121;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3355}',
    parent_cfga_ids = '{19463}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 137;

update flow.data_view_field_config dvfc
set parent_ps_ids = '{3587}',
    parent_cfga_ids = '{24887}',
    reset_values_on_main = true,
    ignore_if_null =true
where id = 616;


