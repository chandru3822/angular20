DROP FUNCTION IF EXISTS brs.check_valid_utility_for_proposals(p_project_process_step_id bigint);
CREATE OR REPLACE FUNCTION brs.check_valid_utility_for_proposals(p_project_process_step_id bigint)
  RETURNS boolean
  LANGUAGE plpgsql
AS
$function$
declare
  v_utility_company_id     bigint;
  v_found_utility_id bigint;
BEGIN

  select int_value
  into v_utility_company_id
  from flow.project_process_step_custom_field_value ppscfv
  where project_process_step_id = p_project_process_step_id
    and ppscfv.custom_field_group_assignment_id = 23802;

  with version_values as (select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) id,
                                                                                                       custom_field_group_assignment_id,
                                                                                                       proposal_group_uuid,
                                                                                                       proposal_version_id,
                                                                                                       value,
                                                                                                       field_id,
                                                                                                       field_code,
                                                                                                       modified_by_id,
                                                                                                       modified_by,
                                                                                                       date_modified
                          from brs.proposal_version_custom_field_value_vw
                          where proposal_version_id <= (select proposal_version_id
                                                        from brs.primary_company_proposal_version
                                                        where company_id = 3
                                                        limit 1)
                            and object_code = 'PROPOSAL_PRICING'
                          order by proposal_group_uuid, custom_field_group_assignment_id, date_modified desc)
  select distinct (value ->> 'intValue')::bigint as utility_id
  into v_found_utility_id
  from version_values
  where custom_field_group_assignment_id = 85
    and (value ->> 'intValue')::bigint = v_utility_company_id;

  if v_found_utility_id is null then
    return false;
  else
    return true;
  end if;

END
$function$
