drop function if exists brs.get_partner_projects(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.get_partner_projects(p_project_id bigint)
  RETURNS bigint[]
AS
$BODY$
declare
  v_org_ids bigint[];
  v_CFGA_PARTNER_ORG_ASSIGNMENT bigint[];
BEGIN

  select (select string_to_array(value, ',')
          from flow.company_configuration_value
          where code = 'CFGA_PARTNER_ORG_ASSIGNMENT')::bigint[]
  into v_CFGA_PARTNER_ORG_ASSIGNMENT;

  select ARRAY_AGG(int_value::bigint)::bigint[]
  into v_org_ids
  from flow.project_custom_field_value pcfv
  where pcfv.project_id = p_project_id and
        pcfv.custom_field_group_assignment_id = any(v_CFGA_PARTNER_ORG_ASSIGNMENT);

  return v_org_ids;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
