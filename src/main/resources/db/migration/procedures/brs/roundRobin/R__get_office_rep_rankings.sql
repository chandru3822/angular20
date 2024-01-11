drop function if exists brs.get_office_rep_rankings(p_time_interval bigint);
CREATE OR REPLACE FUNCTION brs.get_office_rep_rankings(p_time_interval bigint)
  RETURNS table
          (
            user_id                 bigint,
            name                    text,
            office_name             character varying,
            region                  character varying,
            metro_area              character varying,
            lead_gen_fdc_percentage numeric,
            self_gen_fdc            bigint,
            total_fdc               bigint
          )
AS
$BODY$
declare
  v_closer_gen_source_ids bigint[];
BEGIN
  select (select string_to_array(value, ',')
          from flow.company_configuration_value
          where code = 'CLOSER_GEN_SOURCE_IDS')::bigint[]
  into v_closer_gen_source_ids;

  return query
    with position_ids as (select unnest(string_to_array(value, ',')::bigint[]) as id
                          from flow.company_configuration_value
                          where code = 'CLOSER_POSITION_IDS'),
         current_closers as (select distinct u.id,
                                             concat(u.first_name, ' ', u.last_name) AS name,
                                             o.org_name                             as office_name,
                                             o2.org_name                            as region,
                                             coalesce(lov.name, '--')               as metro_area
                             from flow.user_position up
                                    inner join position_ids pi on up.position_id = pi.id
                                    INNER JOIN flow.org o ON o.id = up.org_id
                                    INNER JOIN flow.org o2 ON (o2.id = o.parent_org_id and o2.org_type_id = 117)
                                    INNER JOIN flow.user u ON u.id = up.user_id
                                    INNER JOIN flow.company_user_status cus on cus.user_id = u.id
                                    INNER JOIN flow.user_status_type ust
                                               on ust.id = cus.user_status_type_id and ust.company_id = 3
                                    LEFT JOIN flow.organization_custom_field_value ocfv
                                              ON ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
                                    LEFT JOIN flow.list_of_value lov ON ocfv.int_value = lov.id
                             where up.archived IS FALSE
                               AND up.primary_flag IS true
                               AND (up.end_date is null or up.end_date >= now())
                               AND ust.has_access is true)
      ,
         foo as (SELECT cc.id,
                        cc.name,
                        cc.office_name,
                        cc.region,
                        cc.metro_area,
                        fdc_counts.lead_gen_fdc_count         as leadGenFdcPercentageNumerator,
                        fdc_counts.lead_gen_appointment_count as leadGenFdcPercentageDenominator,
                        fdc_counts.self_gen_fdc_count         as selfGenFdc,
                        fdc_counts.total_fdc_count            as totalFdc
--                       INNER JOIN flow.company_project_status_type cp on pd.company_project_status_type_id = cp.id --being used??
                 from current_closers cc
                        inner join brs.project_details pd on pd.closer_user_id = cc.id
                        left join LATERAL brs.get_fdc_counts(cc.id, v_closer_gen_source_ids, p_time_interval) fdc_counts
                                  on true
                 GROUP BY cc.id, cc.name, cc.office_name, cc.region, cc.metro_area,
                          fdc_counts.lead_gen_fdc_count,
                          fdc_counts.lead_gen_appointment_count,
                          fdc_counts.self_gen_fdc_count,
                          fdc_counts.total_fdc_count)
    select foo.id,
           foo.name,
           foo.office_name,
           foo.region,
           foo.metro_area,
           case
             when foo.leadGenFdcPercentageDenominator < 1 then
               0
             else
               round(
                 (foo.leadGenFdcPercentageNumerator::numeric /
                  foo.leadGenFdcPercentageDenominator::numeric)::numeric *
                 100) end as lead_gen_fdc_percent,
           foo.selfGenFdc,
           foo.totalFdc
    from foo;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
