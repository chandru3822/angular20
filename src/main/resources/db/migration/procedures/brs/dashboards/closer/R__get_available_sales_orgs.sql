drop function if exists brs.get_available_sales_orgs(p_org_id bigint, p_position_id bigint);
CREATE OR REPLACE FUNCTION brs.get_available_sales_orgs(p_org_id bigint, p_position_id bigint)
  RETURNS table
          (
            id   bigint,
            org_name text
          )
  LANGUAGE plpgsql
AS
$function$
DECLARE

BEGIN

  return query
    with orgs as (select ao.id, ao.org_name
                  from flow.org_hierarchy_filter_down(array [p_org_id]) ao
                  where ao.org_type_id in (3,5))
    select org.id, org.org_name
    from flow.org o
           inner join flow.org_type ot on ot.id = o.org_type_id
           inner join flow.org_level ol on ol.id = ot.org_level_id and ol.level < 7
           inner join flow.position p on p.id = p_position_id
           cross join orgs org
    where o.id = p_org_id and
        (p_position_id = any (SELECT unnest(string_to_array(value, ',')::bigint[])
                               FROM flow.company_configuration_value
                               WHERE code = 'CLOSER_POSITION_IDS') or
        p_position_id = any (SELECT unnest(string_to_array(value, ',')::bigint[])
                             FROM flow.company_configuration_value
                             WHERE code = 'SETTER_POSITION_IDS'))
  order by org.org_name;
END
$function$
