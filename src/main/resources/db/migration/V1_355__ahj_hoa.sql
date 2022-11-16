update flow.feature f
set feature_path = '/ahj/list'
where feature_code = 'AHJ_DATABASE';

alter table brs.object_type
  add column if not exists allow_conditional boolean not null default false;
alter table brs.object_type
  add column if not exists allow_hidden boolean not null default false;
alter table brs.object_type
  add column if not exists allow_readonly boolean not null default false;

update brs.object_type ot
set allow_required = false,
    allow_conditional = false,
    allow_hidden = false,
    allow_readonly = false
where object_code in (
                      'AHJ_DESIGN',
                      'AHJ_HOA',
                      'AHJ_INSPECTION',
                      'AHJ_PERMIT',
                      'AHJ_UTILITY'
  );

update brs.object_type ot
set allow_conditional = true,
    allow_hidden = true,
    allow_readonly = true
where object_code in ('PROPOSAL');

update brs.object_type ot
set allow_min_max = true
where object_code in ('PROPOSAL_STORAGE_DETAILS');

update brs.object_type ot
set allow_required = false
where object_code in (
'PROPOSAL_DISCOUNTS',
'PROPOSAL_EQUIPMENT_ADDERS',
'PROPOSAL_FINANCE_PRODUCTS',
'PROPOSAL_FINANCIERS',
'PROPOSAL_INVERTER_DETAILS',
'PROPOSAL_MISC_ADDERS',
'PROPOSAL_PANEL_DETAIL',
'PROPOSAL_PRICING',
'PROPOSAL_REBATE',
'PROPOSAL_SMALL_SYSTEM_ADDERS',
'PROPOSAL_SOURCE_STATE_ADDERS',
'PROPOSAL_STORAGE_DETAILS',
'PROPOSAL_ZONE_ADDERS');
