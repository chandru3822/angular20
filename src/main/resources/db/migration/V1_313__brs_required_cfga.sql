alter table brs.custom_field_group_assignment
  add column if not exists required boolean not null default false;

alter table brs.object_type
  add column if not exists allow_required boolean not null default false;

update brs.object_type set allow_required = true
where object_code in (
'AHJ_DESIGN',
'AHJ_UTILITY',
'AHJ_INSPECTION',
'AHJ_PERMIT',
'PROPOSAL',
'PROPOSAL_PRICING',
'PROPOSAL_REBATE',
'PROPOSAL_ZONE_ADDERS',
'PROPOSAL_FINANCIERS',
'PROPOSAL_FINANCE_PRODUCTS',
'PROPOSAL_EQUIPMENT_ADDERS',
'PROPOSAL_MISC_ADDERS',
'PROPOSAL_SOURCE_STATE_ADDERS',
'PROPOSAL_SMALL_SYSTEM_ADDERS',
'PROPOSAL_PANEL_DETAIL',
'PROPOSAL_INVERTER_DETAILS',
'PROPOSAL_DISCOUNTS'
);

alter table brs.object_type
  add column if not exists allow_min_max boolean not null default false;

update brs.object_type set allow_min_max = true
where object_code in (
      'PROPOSAL_PRICING',
      'PROPOSAL_REBATE',
      'PROPOSAL_ZONE_ADDERS',
      'PROPOSAL_FINANCIERS',
      'PROPOSAL_FINANCE_PRODUCTS',
      'PROPOSAL_EQUIPMENT_ADDERS',
      'PROPOSAL_MISC_ADDERS',
      'PROPOSAL_SOURCE_STATE_ADDERS',
      'PROPOSAL_SMALL_SYSTEM_ADDERS',
      'PROPOSAL_PANEL_DETAIL',
      'PROPOSAL_INVERTER_DETAILS',
      'PROPOSAL_DISCOUNTS'
  );

alter table brs.custom_field_group_assignment
  add column if not exists min_value numeric(10,2);
alter table brs.custom_field_group_assignment
  add column if not exists max_value numeric(10,2);
