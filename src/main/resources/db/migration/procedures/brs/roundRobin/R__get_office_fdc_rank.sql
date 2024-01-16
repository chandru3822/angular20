drop function if exists brs.get_office_fdc_rank(p_org_id bigint, p_time_interval bigint);
CREATE OR REPLACE FUNCTION brs.get_office_fdc_rank(p_org_id bigint, p_time_interval bigint)
  RETURNS table
          (
            user_id              bigint,
            name          text,
            lead_gen_fdc_percentage numeric,
            self_gen_fdc             bigint,
            total_fdc            bigint
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
    with users as (
      SELECT u.id,up.id as user_position_id,u.first_name,u.last_name
      FROM brs.project_details pd
             INNER JOIN flow.user u ON u.id = pd.closer_user_id
             INNER JOIN flow.user_position up ON up.user_id = u.id and up.id = pd.closer_user_position_id
             INNER JOIN flow.company_user_status cus on cus.user_id = u.id
             INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
             INNER JOIN flow.org o ON o.id = up.org_id
             INNER JOIN flow.org o2 ON (o2.id = o.parent_org_id and o2.org_type_id = 117)
      WHERE up.org_id = p_org_id
        AND ust.has_access is true
        AND pd.company_id = 3
        and (up.end_date is null or
             up.end_date >= (now() at time zone 'US/Mountain')::date - (p_time_interval || 'day')::interval)
      GROUP BY u.id,up.id,u.first_name,u.last_name
    )
    select foo.id                                                                  as user_id,
           foo.name,
           case when foo.leadGenFdcPercentageDenominator < 1 then
             0 else
           round((foo.leadGenFdcPercentageNumerator::numeric / foo.leadGenFdcPercentageDenominator::numeric)::numeric * 100) end as lead_gen_fdc_percent,
           foo.selfGenFdc,
           foo.totalFdc
    from (SELECT u.id,
                 concat(u.first_name, ' ', u.last_name) AS name,
                 fdc_counts.lead_gen_fdc_count          as leadGenFdcPercentageNumerator,
                 fdc_counts.lead_gen_appointment_count  as leadGenFdcPercentageDenominator,
                 fdc_counts.self_gen_fdc_count          as selfGenFdc,
                 fdc_counts.total_fdc_count             as totalFdc
          FROM brs.project_details pd
                inner join users u on u.id = pd.closer_user_id
                 left join LATERAL brs.get_fdc_counts(u.id,u.user_position_id, v_closer_gen_source_ids,
                                                      p_time_interval) fdc_counts on true
          GROUP BY u.id,u.user_position_id,u.first_name,u.last_name, fdc_counts.lead_gen_fdc_count,
                   fdc_counts.lead_gen_appointment_count,
                   fdc_counts.self_gen_fdc_count,
                   fdc_counts.total_fdc_count) as foo;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
