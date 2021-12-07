create table brs.proposal_version_status
(
  id                           int not null primary key,
  proposal_version_status_code varchar(20)
);
insert into brs.proposal_version_status (id, proposal_version_status_code)
values (1, 'DRAFT'),
       (2, 'PUBLISHED');

create table brs.proposal_version
(
  id                         serial primary key        not null,
  company_id                 int                       not null references flow.company (id),
  version                    varchar(20),
  proposal_version_status_id int                       not null references brs.proposal_version_status (id),
  notes                      text,

  --     audit cols
  date_created               timestamptz DEFAULT now() not null,
  date_modified              timestamptz DEFAULT now() not null,
  created_by_id              int                       not null references flow.user (id),
  modified_by_id             int                       not null references flow.user (id)
);
create index proposal_version_company_id_ix on brs.proposal_version (company_id);
create index proposal_version_proposal_version_status_id_ix on brs.proposal_version (proposal_version_status_id);

drop table if exists brs.primary_company_proposal_version;
create table brs.primary_company_proposal_version
(
  company_id          int         not null primary key references flow.company (id),
  version_number      int         not null default 1,
  proposal_version_id int         null references brs.proposal_version (id),

  --     audit cols
  date_created        timestamptz not null default now(),
  date_modified       timestamptz not null default now(),
  created_by_id       int         not null references flow.user (id),
  modified_by_id      int         not null references flow.user (id)
);
create index cpc_active_proposal_version_id_ix on brs.primary_company_proposal_version (proposal_version_id);

drop table if exists brs.proposal_version_custom_field_group cascade;
create table brs.proposal_version_custom_field_group
(
  id                  serial      not null primary key,
  proposal_version_id int         not null references brs.proposal_version (id),
  proposal_group_uuid UUID        not null,
  archived            timestamptz null,

  --     audit cols
  date_created        timestamptz not null default now(),
  date_modified       timestamptz not null default now(),
  created_by_id       int         not null references flow.user (id),
  modified_by_id      int         not null references flow.user (id)
);

alter table brs.proposal_version_custom_field_group
  add constraint pvcfg_excl
    exclude (proposal_version_id with =, proposal_group_uuid with = ) where (archived is null);

create index pvcfg_proposal_version_id_ix on brs.proposal_version_custom_field_group (proposal_version_id);
create index pvcfg_proposal_group_uuid_ix on brs.proposal_version_custom_field_group (proposal_group_uuid);

create table brs.proposal_version_custom_field_value
(
  id                                     serial primary key,
  proposal_version_custom_field_group_id integer     not null
    references brs.proposal_version_custom_field_group (id),
  custom_field_group_assignment_id       integer     not null
    references brs.custom_field_group_assignment (id),

-- TODO: change from value
  value                                  jsonb,

--     audit cols
  date_created                           timestamptz not null default now(),
  date_modified                          timestamptz not null default now(),
  created_by_id                          int         not null references flow.user (id),
  modified_by_id                         int         not null references flow.user (id),

  constraint proposal_version_custom_field_value_ux
    unique (proposal_version_custom_field_group_id, custom_field_group_assignment_id)
);

create table brs.proposal_status
(
  id                   int primary key not null,
  proposal_status_code varchar(50)
);
insert into brs.proposal_status (id, proposal_status_code)
VALUES (1, 'REQUESTED'),
       (2, 'PENDING'),
       (3, 'APPROVED'),
       (4, 'CANCELED');

alter table brs.object_type
  add if not exists parent_id int;

alter table brs.object_type
  drop constraint if exists object_type_object_type_id_fk;
alter table brs.object_type
  add constraint object_type_object_type_id_fk
    foreign key (parent_id) references brs.object_type;

create unique index if not exists object_type_ux on brs.object_type (object_code);
create index if not exists object_type_parent_id_ix on brs.object_type (parent_id);

insert into brs.object_type (object_type, object_code)
VALUES ('Proposal', 'PROPOSAL')
on conflict (object_code) do nothing;

insert into brs.object_type (object_type, object_code, parent_id)
VALUES ('Pricing', 'PROPOSAL_PRICING', (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Rebates', 'PROPOSAL_REBATE', (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Zone Adders', 'PROPOSAL_ZONE_ADDERS', (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Financiers', 'PROPOSAL_FINANCIERS', (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Finance Products', 'PROPOSAL_FINANCE_PRODUCTS',
        (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Equipment Adders', 'PROPOSAL_EQUIPMENT_ADDERS',
        (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Miscellaneous Adders', 'PROPOSAL_MISC_ADDERS',
        (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Source & State Adders', 'PROPOSAL_SOURCE_STATE_ADDERS',
        (select id from brs.object_type where object_code = 'PROPOSAL'))
on conflict (object_code) do nothing;

alter table brs.custom_field
  add column if not exists custom_field_sql_key varchar(100);
alter table brs.custom_field
  add column if not exists custom_field_sql_reference_table varchar(100);

drop view if exists brs.proposal_version_custom_field_value_vw;
create or replace view brs.proposal_version_custom_field_value_vw as
(
select pvcfv.id,
       pvcfv.custom_field_group_assignment_id,
       pvcfg.proposal_group_uuid,
       pvcfg.proposal_version_id,
       pvcfv.value,
       cf.field_code,
       cf.field_name,
       ot.object_code,
       pvcfv.modified_by_id,
       concat_ws(' ', mu.first_name, mu.last_name) as modified_by,
       pvcfv.date_modified
from brs.proposal_version_custom_field_value pvcfv
       inner join brs.proposal_version_custom_field_group pvcfg
                  on pvcfv.proposal_version_custom_field_group_id = pvcfg.id
       inner join brs.proposal_version pv on pvcfg.proposal_version_id = pv.id
       inner join brs.custom_field_group_assignment cfga on pvcfv.custom_field_group_assignment_id = cfga.id
       inner join brs.custom_field cf on cfga.custom_field_id = cf.id
       inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
       inner join brs.object_type ot on cfg.object_type_id = ot.id
       inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
       inner join flow.data_type dt on cdt.data_type_id = dt.id
       inner join flow.user mu on mu.id = pvcfv.modified_by_id
where pvcfg.archived is null
  );

drop function if exists brs.upsert_proposal_custom_field_group(bigint, uuid, bigint);
create or replace function brs.upsert_proposal_custom_field_group(p_proposal_version bigint, p_group_uuid uuid, p_current_user bigint)
  returns int as
$$
declare
  ret int;
begin

  select id
  into ret
  from brs.proposal_version_custom_field_group
  where proposal_version_id = p_proposal_version
    and proposal_group_uuid = p_group_uuid
    and archived is null;

  if ret is null then
    insert into brs.proposal_version_custom_field_group (proposal_version_id, proposal_group_uuid, date_created,
                                                         date_modified, created_by_id, modified_by_id)
    values (p_proposal_version, p_group_uuid, now(), now(), p_current_user, p_current_user)
    returning id into ret;
  end if;

  return ret;
end;
$$ language plpgsql;



-- TODO: add later
-- create table brs.proposal_attachment
-- (
--   id            serial primary key not null,
--   proposal_id   int                not null references brs.proposal (id),
--   attachment_id int                not null references flow.attachment (id)
-- );
-- create index proposal_attachment_proposal_id_ix on brs.proposal_attachment (proposal_id);
-- create index proposal_attachment_attachment_id_ix on brs.proposal_attachment (attachment_id);
--
-- insert into flow.attachment_type (attachment_type, attachment_code, company_id, key_pattern_id,
--                                   date_created, date_modified, created_by_id, modified_by_id)
-- values ('Proposal', 'PROPOSAL', 3, 7, now(), now(), 2350555, 2350555);

-- create table brs.equipment_panel
-- (
--   id                serial primary key not null,
--   name              varchar(100)       not null,
--   brand             varchar(100)       not null,
--   model             varchar(100)       not null,
--   wattage           varchar(100)       not null,
--   solar_degradation varchar(100)       not null
-- );

-- TODO: add in ref to state
-- create table brs.equipment_panel_state
-- (
--     panel_id int not null references brs.equipment_panel(id),
--     state_id int not null references brs.
-- );

-- create table brs.equipment_inverter
-- (
--   id            serial primary key not null,
--   name          varchar(100)       not null,
--   brand         varchar(100)       not null,
--   model         varchar(100)       not null,
--   inverter_type varchar(100)       not null,
--   power_rating  varchar(100)       not null
-- );
--
-- create table brs.equipment_panel_inverter
-- (
--   panel_id    int not null references brs.equipment_panel (id),
--   inverter_id int not null references brs.equipment_inverter (id),
--   primary key (panel_id, inverter_id)
-- );


-- **** NOTE: Data ONLY **** --

-- TODO: change to the right object type based on ^^

---pricing tab custom fields
create temporary sequence if not exists pricing_group_seq start 1;
with pricing_group as (
  insert into brs.custom_field_group
    (group_name, object_type_id, group_order, archived,
     date_created, date_modified, created_by_id, modified_by_id)
    values ('Pricing',
            (select id from brs.object_type where object_code = 'PROPOSAL_PRICING' LIMIT 1),
            1,
            false,
            now(),
            now(),
            2350555,
            2350555)
    returning id
),
     pricing_custom_fields as (
       insert
         into brs.custom_field
           (list_of_value_id, field_name, field_code, company_data_type_id,
            date_created, date_modified, created_by_id, modified_by_id)
           VALUES
             --TODO: point to AHJ Database
             (null, 'Utility Company', 'UTILITY_COMPANY', 1, now(), now(), 2350555, 2350555),
             --TODO: point to state lists
             (null, 'State', 'STATE', 1, now(), now(), 2350555, 2350555),
             (null, 'kWh', 'KWH', 6, now(), now(), 2350555, 2350555),
             (null, 'Payment Factor for East/West Roofs', 'PAYMENT_FACTOR_EW_ROOFS', 6, now(), now(), 2350555,
              2350555),
             (null, 'Payment Factor for South Roofs', 'PAYMENT_FACTOR_S_ROOFS', 6, now(), now(), 2350555,
              2350555),
             (null, 'Max funding amount', 'MAX_FUNDING_AMOUNT', 6, now(), now(), 2350555, 2350555),
             (null, 'Min funding amount', 'MIN_FUNDING_AMOUNT', 6, now(), now(), 2350555, 2350555),
             (null, 'Net Metering Rate', 'NET_METERING_RATE', 6, now(), now(), 2350555, 2350555),
             --TODO: create table and point to rebate section
             (null, 'Applicable Rebate(s)', 'APPLICABLE_REBATE', 1, now(), now(), 2350555, 2350555),
             (null, 'Utility Cost Escalator', 'UTILITY_COST_ESCALATOR', 3, now(), now(), 2350555, 2350555)
           returning id
     ),
     custom_object_types as (
       insert into brs.custom_field_object_type (custom_field_id, object_type_id,
                                                 date_created, date_modified, created_by_id, modified_by_id)
         select id,
                (select id from brs.object_type where object_code = 'PROPOSAL' LIMIT 1),
                now(),
                now(),
                2350555,
                2350555
         from pricing_custom_fields
     )
insert
into brs.custom_field_group_assignment
(custom_field_group_id, custom_field_id, field_order,
 date_created, date_modified, created_by_id, modified_by_id)
select pg.id, cf.id, nextval('pricing_group_seq'), now(), now(), 2350555, 2350555
from pricing_group pg,
     pricing_custom_fields cf;

---rebates tab custom fields
create temporary sequence if not exists rebates_group_seq start 1;
with rebates_group as (
  insert into brs.custom_field_group
    (group_name, object_type_id, group_order, archived,
     date_created, date_modified, created_by_id, modified_by_id)
    values ('Rebates', (select id from brs.object_type where object_code = 'PROPOSAL_REBATE' LIMIT 1), 2, false,
            now(),
            now(), 2350555, 2350555)
    returning id
),
     rebate_rebate_type_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Rebate Type', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     rebate_rebate_types as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         select types.name,
                types.code,
                p.id,
                types.display_order,
                now(),
                now(),
                2350555,
                2350555
         from rebate_rebate_type_parent p,
              (values ('Federal', 'FEDERAL', 1),
                      ('State', 'STATE', 2),
                      ('Local', 'LOCAL', 3),
                      ('Utility', 'UTILITY', 4),
                      ('Other', 'OTHER', 5)) types (name, code, display_order)
     ),
     rebate_unit_type_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Unit Type', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     rebate_unit_types as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         select types.name,
                types.code,
                p.id,
                types.display_order,
                now(),
                now(),
                2350555,
                2350555
         from rebate_unit_type_parent p,
              (values ('Percentage of Total', 'PCT_OF_TOTAL', 1),
                      ('Flat Dollar Amount', 'FLAT_DOLLAR_AMOUNT', 2)) types (name, code, display_order)
     ),
     rebates_custom_fields as (
       insert
         into brs.custom_field
           (list_of_value_id, field_name, field_code, company_data_type_id,
            date_created, date_modified, created_by_id, modified_by_id)
           VALUES (null, 'Name', 'REBATE_NAME', 1, now(), now(), 2350555, 2350555),
                  ((select id from rebate_rebate_type_parent), 'Rebate Type', 'REBATE_TYPE', 7, now(), now(),
                   2350555, 2350555),
                  ((select id from rebate_unit_type_parent), 'Unit Type', 'REBATE_UNIT_TYPE', 7, now(), now(),
                   2350555, 2350555),
                  (null, 'Amount', 'REBATE_AMOUNT', 6, now(), now(), 2350555, 2350555),
                  (null, 'First Year Cap on Rebate Capture?', 'REBATE_FIRST_YEAR_CAP', 3, now(), now(), 2350555,
                   2350555),
                  (null, 'Max amount captured in first year', 'REBATE_MAX_AMOUNT_CAP_FIRST_YEAR', 6, now(), now(),
                   2350555, 2350555),
                  (null, 'Rebate Cap', 'REBATE_REBATE_CAP', 6, now(), now(), 2350555, 2350555)
           returning id
     ),
     custom_object_types as (
       insert into brs.custom_field_object_type (custom_field_id, object_type_id,
                                                 date_created, date_modified, created_by_id, modified_by_id)
         select id,
                (select id from brs.object_type where object_code = 'PROPOSAL' LIMIT 1),
                now(),
                now(),
                2350555,
                2350555
         from rebates_custom_fields
     )
insert
into brs.custom_field_group_assignment
(custom_field_group_id, custom_field_id, field_order,
 date_created, date_modified, created_by_id, modified_by_id)
select pg.id, cf.id, nextval('rebates_group_seq'), now(), now(), 2350555, 2350555
from rebates_group pg,
     rebates_custom_fields cf;

--- zone adder tab custom fields
create temporary sequence if not exists zone_adders_group_seq start 1;
with zone_adders_group as (
  insert into brs.custom_field_group
    (group_name, object_type_id, group_order, archived,
     date_created, date_modified, created_by_id, modified_by_id)
    values ('Zone Adder', (select id from brs.object_type where object_code = 'PROPOSAL_ZONE_ADDERS' LIMIT 1), 3,
            false, now(),
            now(), 2350555, 2350555)
    returning id
),
--      TODO: should come through flow.state
     zone_state_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('State(s)', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     zone_adders_group_custom_fields as (
       insert
         into brs.custom_field
           (list_of_value_id, field_name, field_code, company_data_type_id,
            date_created, date_modified, created_by_id, modified_by_id)
           VALUES ((select id from zone_state_parent), 'State', 'ZONE_ADDERS_STATE', 7, now(), now(), 2350555,
                   2350555),
                  (null, 'Zone Name', 'ZONE_ADDERS_ZONE_NAME', 1, now(), now(), 2350555, 2350555),
                  (null, 'Postal Codes', 'ZONE_ADDERS_POSTAL_CODES', 1, now(), now(), 2350555,
                   2350555), --TODO: rename to whatever we call the custom array
                  (null, 'Adder', 'ZONE_ADDERS_VALUE', 6, now(), now(), 2350555, 2350555)
           returning id
     ),
     custom_object_types as (
       insert into brs.custom_field_object_type (custom_field_id, object_type_id,
                                                 date_created, date_modified, created_by_id, modified_by_id)
         select id,
                (select id from brs.object_type where object_code = 'PROPOSAL' LIMIT 1),
                now(),
                now(),
                2350555,
                2350555
         from zone_adders_group_custom_fields
     )
insert
into brs.custom_field_group_assignment
(custom_field_group_id, custom_field_id, field_order,
 date_created, date_modified, created_by_id, modified_by_id)
select pg.id, cf.id, nextval('zone_adders_group_seq'), now(), now(), 2350555, 2350555
from zone_adders_group pg,
     zone_adders_group_custom_fields cf;

---financiers tab custom fields
create temporary sequence if not exists financiers_group_seq start 1;
with financiers_group as (
  insert into brs.custom_field_group
    (group_name, object_type_id, group_order, archived,
     date_created, date_modified, created_by_id, modified_by_id)
    values ('Financiers', (select id from brs.object_type where object_code = 'PROPOSAL_FINANCIERS' LIMIT 1), 4,
            false, now(),
            now(), 2350555, 2350555)
    returning id
),
     financiers_non_solar_type_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Additional fee for exceeding non-solar threshold type', null, null, 1, now(), now(), 2350555,
                 2350555)
         returning id
     ),
     financiers_non_solar_types as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         select types.name,
                types.code,
                p.id,
                types.display_order,
                now(),
                now(),
                2350555,
                2350555
         from financiers_non_solar_type_parent p,
              (values ('Flat Fee', 'FLAT_FEE', 1),
                      ('% of Total', 'PCT_OF_TOTAL', 2),
                      ('Price per Watt', 'PRICE_PER_WATT', 3)) types (name, code, display_order)
     ),
     financiers_custom_fields as (
       insert
         into brs.custom_field
           (list_of_value_id, field_name, field_code, company_data_type_id,
            date_created, date_modified, created_by_id, modified_by_id)
           VALUES
             --TODO: this should be tied to the `brs.financier` table
             (null, 'Financier', 'FINANCIERS_NAME', 1, now(), now(), 2350555, 2350555),
             (null, 'Non-solar Threshold for additional fee', 'FINANCIERS_NON_SOLAR_THRESHOLD_ADD_FEE', 6,
              now(), now(), 2350555, 2350555),
             (null, 'Storage included as "solar"', 'FINANCIERS_STORAGE_INCLUDED_AS_SOLAR', 4, now(), now(),
              2350555, 2350555),
             (null, 'Max Price per Watt - Solar', 'FINANCIERS_MAX_PRICE_PER_WATT', 6, now(), now(), 2350555,
              2350555),
             (null, 'Non-solar Cap', 'FINANCIERS_NON_SOLAR_CAP', 6, now(), now(), 2350555, 2350555),
             ((select id from financiers_non_solar_type_parent),
              'Additional fee for exceeding non-solar threshold type',
              'FINANCIERS_ADD_FEE_EXCEEDING_NON_SOLAR_TYPE', 7, now(), now(), 2350555, 2350555),
             (null, 'Additional fee for exceeding non-solar threshold', 'FINANCIERS_ADD_FEE_THRESHOLD_VALUE',
              6, now(), now(), 2350555, 2350555),
             (null, 'Adder for ancillary % of solar', 'FINANCIERS_ADD_ANCILLARY_PCT_SOLAR', 6, now(), now(),
              2350555, 2350555)
           returning id
     ),
     custom_object_types as (
       insert into brs.custom_field_object_type (custom_field_id, object_type_id,
                                                 date_created, date_modified, created_by_id, modified_by_id)
         select id,
                (select id from brs.object_type where object_code = 'PROPOSAL' LIMIT 1),
                now(),
                now(),
                2350555,
                2350555
         from financiers_custom_fields
     )
insert
into brs.custom_field_group_assignment
(custom_field_group_id, custom_field_id, field_order,
 date_created, date_modified, created_by_id, modified_by_id)
select pg.id, cf.id, nextval('financiers_group_seq'), now(), now(), 2350555, 2350555
from financiers_group pg,
     financiers_custom_fields cf;

---finance products tab custom fields
create temporary sequence if not exists finance_products_group_seq start 1;
with finance_products_group as (
  insert into brs.custom_field_group
    (group_name, object_type_id, group_order, archived,
     date_created, date_modified, created_by_id, modified_by_id)
    values ('Finance Products',
            (select id from brs.object_type where object_code = 'PROPOSAL_FINANCE_PRODUCTS' LIMIT 1), 5, false,
            now(), now(), 2350555, 2350555)
    returning id
),
     finance_products_brs_products_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Eligible BRS Product(s)', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     finance_products_brs_products_types as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         select types.name,
                types.code,
                p.id,
                types.display_order,
                now(),
                now(),
                2350555,
                2350555
         from finance_products_brs_products_parent p,
              (values ('BluePower', 'BLUEPOWER', 1),
                      ('BluePower+', 'BLUEPOWER+', 2)) types (name, code, display_order)
     ),
     finance_products_group_custom_fields as (
       insert
         into brs.custom_field
           (list_of_value_id, field_name, field_code, company_data_type_id,
            date_created, date_modified, created_by_id, modified_by_id)
           VALUES (null, 'Name', 'FINANCE_PRODUCTS_NAME', 1, now(), now(), 2350555, 2350555),
                  --drop down of financiers
                  (null, 'Financier', 'FINANCE_PRODUCTS_FINANCIER', 1, now(), now(), 2350555,
                   2350555),
                  (null, 'Loan Term', 'FINANCE_PRODUCTS_LOAN_TERM', 5, now(), now(), 2350555, 2350555),
                  (null, 'Rate (APR)', 'FINANCE_PRODUCTS_RATE_APR', 6, now(), now(), 2350555, 2350555),
                  ((select id from finance_products_brs_products_parent), 'Eligible BRS Product(s)',
                   'FINANCE_PRODUCTS_ELIGIBLE_BRS_PRODUCTS', 8, now(), now(), 2350555, 2350555),
                  (null, 'Dealer fee', 'FINANCE_PRODUCTS_DEALER_FEE', 6, now(), now(), 2350555, 2350555),
                  (null, 'Initial Monthly Payment Factor', 'FINANCE_PRODUCTS_INIT_MONTHLY_PAYMENT_FACTOR', 6,
                   now(), now(), 2350555, 2350555),
                  (null, 'Re-amortized Payment Factor (w/o ITC paydown)',
                   'FINANCE_PRODUCTS_RE_AMOR_PAYMENT_FACTOR', 6, now(), now(), 2350555, 2350555)
           returning id
     ),
     custom_object_types as (
       insert into brs.custom_field_object_type (custom_field_id, object_type_id,
                                                 date_created, date_modified, created_by_id, modified_by_id)
         select id,
                (select id from brs.object_type where object_code = 'PROPOSAL' LIMIT 1),
                now(),
                now(),
                2350555,
                2350555
         from finance_products_group_custom_fields
     )
insert
into brs.custom_field_group_assignment
(custom_field_group_id, custom_field_id, field_order,
 date_created, date_modified, created_by_id, modified_by_id)
select pg.id, cf.id, nextval('finance_products_group_seq'), now(), now(), 2350555, 2350555
from finance_products_group pg,
     finance_products_group_custom_fields cf;

---equipment adders tab custom fields
create temporary sequence if not exists equipment_adders_group_seq start 1;
with equipment_adders_group as (
  insert into brs.custom_field_group
    (group_name, object_type_id, group_order, archived,
     date_created, date_modified, created_by_id, modified_by_id)
    values ('Equipment Adders',
            (select id from brs.object_type where object_code = 'PROPOSAL_EQUIPMENT_ADDERS' LIMIT 1), 6, false,
            now(), now(), 2350555, 2350555)
    returning id
),
     equipment_adders_type_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Equipment Type', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
--      TODO: shouldn't these be part of the equipement table?
     equipment_adders_types as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         select types.name,
                types.code,
                p.id,
                types.display_order,
                now(),
                now(),
                2350555,
                2350555
         from equipment_adders_type_parent p,
              (values ('Panel', 'PANEL', 1),
                      ('Inverter', 'INVERTER', 2),
                      ('Storage', 'STORAGE', 3)) types (name, code, display_order)
     ),
--      TODO: does this come through some other relationship?
     equipment_adders_utility_companies_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Utility Company (s)', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     equipment_adders_adder_type_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Adder Type', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     equipment_adders_adder_types as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         select types.name,
                types.code,
                p.id,
                types.display_order,
                now(),
                now(),
                2350555,
                2350555
         from equipment_adders_adder_type_parent p,
              (values ('Per Watt', 'PER_WATT', 1),
                      ('FLAT_FEE', 'FLAT_FEE', 2)) types (name, code, display_order)
     ),
     equipment_adders_group_custom_fields as (
       insert
         into brs.custom_field
           (list_of_value_id, field_name, field_code, company_data_type_id,
            date_created, date_modified, created_by_id, modified_by_id)
           VALUES ((select id from equipment_adders_type_parent), 'Equipment Type', 'EQUIP_ADDERS_EQUIPMENT_TYPE',
                   7, now(), now(), 2350555, 2350555),
                  (null, 'Name', 'EQUIP_ADDERS_NAME', 1, now(), now(), 2350555,
                   2350555), --drop down of financiers
                  ((select id from equipment_adders_utility_companies_parent), 'Utility Company(s)',
                   'EQUIP_ADDERS_UTILITY_COMPANY', 8, now(), now(), 2350555, 2350555),
                  ((select id from equipment_adders_adder_type_parent), 'Adder Type', 'EQUIP_ADDERS_ADDER_TYPE',
                   7, now(), now(), 2350555, 2350555),
                  (null, 'Adder', 'EQUIP_ADDERS_ADDER_VALUE', 6, now(), now(), 2350555, 2350555)
           returning id
     ),
     custom_object_types as (
       insert into brs.custom_field_object_type (custom_field_id, object_type_id,
                                                 date_created, date_modified, created_by_id, modified_by_id)
         select id,
                (select id from brs.object_type where object_code = 'PROPOSAL' LIMIT 1),
                now(),
                now(),
                2350555,
                2350555
         from equipment_adders_group_custom_fields
     )
insert
into brs.custom_field_group_assignment
(custom_field_group_id, custom_field_id, field_order,
 date_created, date_modified, created_by_id, modified_by_id)
select pg.id, cf.id, nextval('equipment_adders_group_seq'), now(), now(), 2350555, 2350555
from equipment_adders_group pg,
     equipment_adders_group_custom_fields cf;

---misc adders tab custom fields
create temporary sequence if not exists misc_adders_group_seq start 1;
with misc_adders_group as (
  insert into brs.custom_field_group
    (group_name, object_type_id, group_order, archived,
     date_created, date_modified, created_by_id, modified_by_id)
    values ('Miscellaneous Adders',
            (select id from brs.object_type where object_code = 'PROPOSAL_MISC_ADDERS' LIMIT 1), 7,
            false, now(), now(), 2350555, 2350555)
    returning id
),
--      TODO: does this come through some other relationship?
     misc_adders_utility_companies_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Utility Company (s)', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
--      TODO: reuse adder type
     misc_adders_adder_type_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Adder Type', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     misc_adders_adder_types as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         select types.name,
                types.code,
                p.id,
                types.display_order,
                now(),
                now(),
                2350555,
                2350555
         from misc_adders_adder_type_parent p,
              (values ('Per Watt', 'PER_WATT', 1),
                      ('FLAT_FEE', 'FLAT_FEE', 2)) types (name, code, display_order)
     ),
     misc_adders_group_custom_fields as (
       insert
         into brs.custom_field
           (list_of_value_id, field_name, field_code, company_data_type_id,
            date_created, date_modified, created_by_id, modified_by_id)
           VALUES (null, 'Name', 'MISC_ADDERS_NAME', 1, now(), now(), 2350555, 2350555), --drop down of financiers
                  ((select id from misc_adders_utility_companies_parent), 'Utility Company(s)',
                   'MISC_ADDERS_UTILITY_COMPANY', 8, now(), now(), 2350555, 2350555),
                  ((select id from misc_adders_adder_type_parent), 'Adder Type', 'MISC_ADDERS_ADDER_TYPE', 7,
                   now(), now(), 2350555, 2350555),
                  (null, 'Adder', 'MISC_ADDERS_ADDER_VALUE', 6, now(), now(), 2350555, 2350555)
           returning id
     ),
     custom_object_types as (
       insert into brs.custom_field_object_type (custom_field_id, object_type_id,
                                                 date_created, date_modified, created_by_id, modified_by_id)
         select id,
                (select id from brs.object_type where object_code = 'PROPOSAL' LIMIT 1),
                now(),
                now(),
                2350555,
                2350555
         from misc_adders_group_custom_fields
     )
insert
into brs.custom_field_group_assignment
(custom_field_group_id, custom_field_id, field_order,
 date_created, date_modified, created_by_id, modified_by_id)
select pg.id, cf.id, nextval('misc_adders_group_seq'), now(), now(), 2350555, 2350555
from misc_adders_group pg,
     misc_adders_group_custom_fields cf;

---source/state adder tab custom fields
create temporary sequence if not exists source_state_adders_group_seq start 1;
with source_state_adders_group as (
  insert into brs.custom_field_group
    (group_name, object_type_id, group_order, archived,
     date_created, date_modified, created_by_id, modified_by_id)
    values ('Source & State Adder',
            (select id from brs.object_type where object_code = 'PROPOSAL_SOURCE_STATE_ADDERS' LIMIT 1), 8,
            false, now(), now(), 2350555, 2350555)
    returning id
),
--      TODO: does this come through some other relationship?
     source_state_adders_source_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Sources', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     source_state_state_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('State(s)', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
--      TODO: reuse adder type
     source_state_adders_adder_type_parent as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         VALUES ('Adder Type', null, null, 1, now(), now(), 2350555, 2350555)
         returning id
     ),
     source_state_adders_adder_types as (
       insert into brs.list_of_value (name, code, parent_id, display_order,
                                      date_created, date_modified, created_by_id, modified_by_id)
         select types.name,
                types.code,
                p.id,
                types.display_order,
                now(),
                now(),
                2350555,
                2350555
         from source_state_adders_adder_type_parent p,
              (values ('Per Watt', 'PER_WATT', 1),
                      ('FLAT_FEE', 'FLAT_FEE', 2)) types (name, code, display_order)
     ),
     source_state_adders_group_custom_fields as (
       insert
         into brs.custom_field
           (list_of_value_id, field_name, field_code, company_data_type_id,
            date_created, date_modified, created_by_id, modified_by_id)
           VALUES ((select id from source_state_adders_source_parent), 'Source', 'SOURCE_STATE_ADDERS_SOURCE', 7,
                   now(), now(), 2350555, 2350555),
                  ((select id from source_state_state_parent), 'State', 'SOURCE_STATE_STATE', 8, now(), now(),
                   2350555, 2350555),
                  ((select id from source_state_adders_adder_type_parent), 'Adder Type',
                   'SOURCE_STATE_ADDER_TYPE', 7, now(), now(), 2350555, 2350555),
                  (null, 'Adder', 'SOURCE_STATE_ADDER_VALUE', 6, now(), now(), 2350555, 2350555)
           returning id
     ),
     custom_object_types as (
       insert into brs.custom_field_object_type (custom_field_id, object_type_id,
                                                 date_created, date_modified, created_by_id, modified_by_id)
         select id,
                (select id from brs.object_type where object_code = 'PROPOSAL' LIMIT 1),
                now(),
                now(),
                2350555,
                2350555
         from source_state_adders_group_custom_fields
     )
insert
into brs.custom_field_group_assignment
(custom_field_group_id, custom_field_id, field_order,
 date_created, date_modified, created_by_id, modified_by_id)
select pg.id, cf.id, nextval('source_state_adders_group_seq'), now(), now(), 2350555, 2350555
from source_state_adders_group pg,
     source_state_adders_group_custom_fields cf;

-- Just extra queries to help out
select *
from brs.proposal_version_custom_field_value_vw;


with something as (
  select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) id,
                                                                               custom_field_group_assignment_id,
                                                                               proposal_group_uuid,
                                                                               proposal_version_id,
                                                                               value,
                                                                               field_code,
                                                                               modified_by_id,
                                                                               modified_by,
                                                                               date_modified
  from brs.proposal_version_custom_field_value_vw
  where proposal_version_id <= 4
    and object_code = 'PROPOSAL_PRICING'
  order by proposal_group_uuid, custom_field_group_assignment_id, id desc)
select proposal_group_uuid, json_object_agg(field_code, value)
from something
group by 1;



