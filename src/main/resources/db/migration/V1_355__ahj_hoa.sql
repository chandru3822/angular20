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

--todo add kalebs stuff here for allow_* 
