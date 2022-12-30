-- fix a dumb mistake
update flow.custom_field
set custom_field_sql_reference_table = 'brs.feat_db_utility'
where custom_field_sql_reference_table = 'brs.ahj_utility';


alter table flow.custom_field
add column if not exists custom_field_sql text;

alter table flow.custom_field
  add column if not exists custom_field_sql_smartlist text;

alter table brs.custom_field
  add column if not exists custom_field_sql text;

alter table brs.custom_field
  add column if not exists custom_field_sql_smartlist text;


update flow.custom_field cf
set custom_field_sql = 'select a.id,
       a.name
    from brs.feat_db_ahj a
    where archived is not true
    order by a.name',
  custom_field_sql_smartlist = 'select a.id,
       a.name
    from brs.feat_db_ahj a
    where archived is not true'
where custom_field_sql_key = 'customFieldSql.brs.ahjList';

update flow.custom_field cf
set custom_field_sql = 'select a.id,
           a.name
    from brs.feat_db_utility a
    where archived is not true
    order by a.name',
    custom_field_sql_smartlist = 'select a.id,
           a.name
    from brs.feat_db_utility a
    where archived is not true'
where custom_field_sql_key = 'customFieldSql.brs.utilityCompanyList';

update flow.custom_field cf
set custom_field_sql = 'select plh.id,
           plh.proposal_nbr as name
    from brs.proposal_log_history plh
    where plh.project_id = :projectId
    order by plh.proposal_nbr',
    custom_field_sql_smartlist = 'select plh.id,
           plh.proposal_nbr as name
    from brs.proposal_log_history plh'
where custom_field_sql_key = 'customFieldSql.brs.proposalLogNumbers';

update flow.custom_field cf
set custom_field_sql = 'select dlh.id,
           dlh.reference_nbr as name
    from brs.design_log_history dlh
    where dlh.project_id = :projectId
    order by dlh.design_log_id',
    custom_field_sql_smartlist = 'select dlh.id,
             dlh.reference_nbr as name
      from brs.design_log_history dlh'
where custom_field_sql_key = 'customFieldSql.brs.designLogNumbers';

update flow.custom_field cf
set custom_field_sql = 'select concat(''AHJ Specific Requirements: '',  chr(13), chr(13), text_value) as text_value
      from brs.project_details pd
       inner join brs.feat_db_ahj a on a.id = pd.ahj
         inner join brs.feat_db_ahj_inspection ai on ai.ahj_id = a.id
         inner join brs.feat_db_ahj_inspection_custom_field_value aicfv on aicfv.ahj_inspection_id = ai.id
      where custom_field_group_assignment_id = 207
      and pd.project_id = :projectId'
where custom_field_sql_key = 'customFieldSql.brs.ahjSpecificInstallationRequirements';

update flow.custom_field cf
set custom_field_sql = 'select jsonb_pretty(bom::jsonb) as text_value
      from brs.design_log_history dlh
      where project_id = :projectId
      and id = (
        select int_value
        from flow.project_process_step_custom_field_value ppscfv
        where ppscfv.project_process_step_id = :ppsId
          and ppscfv.custom_field_group_assignment_id in (
          select cfga.id
          from flow.custom_field_group_assignment cfga
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
          where cfga.custom_field_id = 9109
            and cfg.process_step_id is not null
            and cfga.archived is false
            and cfg.archived is false'
where custom_field_sql_key = 'customFieldSql.brs.designLogBomValue';

update flow.custom_field cf
set custom_field_sql = '    select to_char(final_design_signed_date, ''FMMM/FMDD/YYYY'') as text_value
    from brs.project_details pd
    where project_id = :projectId'
where custom_field_sql_key = 'customFieldSql.brs.finalDesignSignedDate';

update brs.custom_field cf
set custom_field_sql = 'select s.id,
       s.state as name
from flow.state s
         inner join flow.company_state cs on s.id = cs.state_id
where cs.company_id = :companyId
order by s.state'
where custom_field_sql_key = 'customFieldSql.brs.availableStates';

update brs.custom_field cf
set custom_field_sql = 'select id,
         postal_code as name,
         concat_ws(''/'', place_name, admin_name1) as description
  from flow.postal_code
  where case when :query is not null then postal_code like :query || ''%'' else 1 = 1 end
  order by postal_code asc
  limit 50'
where custom_field_sql_key = 'customFieldSql.flow.postalCodes.lazy';


update brs.custom_field cf
set custom_field_sql = 'select a.id,
           a.name
    from brs.feat_db_utility a
    where archived is not true
    order by a.name',
  custom_field_sql_smartlist = 'select a.id,
           a.name
    from brs.feat_db_utility a
    where archived is not true'
where custom_field_sql_key = 'customFieldSql.brs.utilityCompanyList';

DROP FUNCTION IF EXISTS flow.get_attachment_compare_fields(bigint);
DROP FUNCTION IF EXISTS flow.get_attachment_compare_fields_for_object(bigint, bigint, int);
drop FUNCTION if exists flow.get_project_process_step_event_requirements_with_values(bigint, bigint[]);
drop FUNCTION if exists flow.get_project_process_step_requirements_with_values(bigint, bigint[]);


select *
from flow.custom_field cf
where custom_field_sql_key is not null
-- and custom_field_sql_key not in (
--   'customFieldSql.brs.ahjList',
--   'customFieldSql.brs.utilityCompanyList',
--   'customFieldSql.brs.proposalLogNumbers',
--   'customFieldSql.brs.designLogNumbers',
--   'customFieldSql.brs.designLogBomValue',
--   'customFieldSql.brs.finalDesignSignedDate',
--   'customFieldSql.brs.ahjSpecificInstallationRequirements'
--   )
order by custom_field_sql_key
;

select *
from brs.custom_field cf
where custom_field_sql_key is not null
  and custom_field_sql_key not in (
  'customFieldSql.brs.utilityCompanyList',
  'customFieldSql.flow.postalCodes.lazy',
  'customFieldSql.brs.availableStates'

  )
order by custom_field_sql_key
