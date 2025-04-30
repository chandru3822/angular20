drop function if exists brs.get_closer_rep_rankings(bigint, bigint);
drop function if exists brs.get_closer_rep_rankings(date, date,bigint);
CREATE OR REPLACE FUNCTION brs.get_closer_rep_rankings(p_start_date date,p_end_date date, p_org_id bigint default null )
  RETURNS table
          (
            user_id              bigint,
            closer_name          text,
            office_name             character varying,
            region                  character varying,
            metro_area              character varying,
            lead_gen_fdc_percentage numeric,
            self_gen_fdc             bigint,
            total_fdc            bigint,
            rank bigint,
            rank_label text
          )
AS
$BODY$
declare
  v_closer_gen_source_ids bigint[];
v_time_interval bigint;
BEGIN
  select (select string_to_array(value, ',')
          from flow.company_configuration_value
          where code = 'CLOSER_GEN_SOURCE_IDS')::bigint[]
  into v_closer_gen_source_ids;

  select (p_end_date - p_start_date)::bigint
  into v_time_interval;

  return query
    with position_ids as (select unnest(string_to_array(value, ',')::bigint[]) as id
                          from flow.company_configuration_value
                          where code = 'CLOSER_POSITION_IDS'),
        current_closers as (
      SELECT distinct on (u.id) u.id,up.id as user_position_id,u.first_name,u.last_name,
             o.org_name                             as office_name,
             o2.org_name                            as region,
             coalesce(lov.name, '--')               as metro_area
      FROM brs.project_details pd
             INNER JOIN flow.user u ON u.id = pd.closer_user_id
             INNER JOIN flow.user_position up ON up.user_id = u.id and up.id = pd.closer_user_position_id
             inner join position_ids pi on up.position_id = pi.id
             INNER JOIN flow.company_user_status cus on cus.user_id = u.id
             INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
             INNER JOIN flow.org o ON o.id = up.org_id
             INNER JOIN flow.org o2 ON (o2.id = o.parent_org_id)
             LEFT JOIN flow.organization_custom_field_value ocfv --for now this needs to be the user's metro area, not the project one
                       ON ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
             LEFT JOIN flow.list_of_value lov ON ocfv.int_value = lov.id
      WHERE case when p_org_id is not null then (up.org_id = p_org_id or up.sales_org_id = p_org_id) else true end
        AND ust.has_access is true
        and ust.user_status_type = 'Active'
        and up.archived is false
        AND pd.company_id = 3
        and (up.end_date is null or
             up.end_date >= (now() at time zone 'US/Mountain')::date - (v_time_interval || 'day')::interval)
    ), results as (select foo.id                                                                           as user_id,
                          foo.name,
                          foo.metro_area,
                          foo.region,
                          foo.office_name,
                          case
                              when foo.leadGenFdcPercentageDenominator < 1 then
                                  0
                              else
                                  round((foo.leadGenFdcPercentageNumerator::numeric /
                                         foo.leadGenFdcPercentageDenominator::numeric)::numeric *
                                        100) end                                                           as lead_gen_fdc_percent,
                          foo.self_gen_fdc,
                          foo.total_fdc
                   from (SELECT u.id,
                                concat(u.first_name, ' ', u.last_name) AS name,
                                u.metro_area,
                                u.region,
                                u.office_name,
                                fdc_counts.lead_gen_fdc_count          as leadGenFdcPercentageNumerator,
                                fdc_counts.lead_gen_appointment_count  as leadGenFdcPercentageDenominator,
                                fdc_counts.self_gen_fdc_count          as self_gen_fdc,
                                fdc_counts.total_fdc_count             as total_fdc
                         FROM brs.project_details pd
                                  inner join current_closers u on u.id = pd.closer_user_id
                                  left join LATERAL brs.get_fdc_counts(u.id, u.user_position_id,
                                                                       v_closer_gen_source_ids,
                                                                       v_time_interval) fdc_counts on true
                         GROUP BY u.id, u.user_position_id, u.first_name, u.last_name,
                                  u.metro_area, u.region,
                                  u.office_name,
                                  fdc_counts.lead_gen_fdc_count,
                                  fdc_counts.lead_gen_appointment_count,
                                  fdc_counts.self_gen_fdc_count,
                                  fdc_counts.total_fdc_count) as foo)
  select r.user_id,
         r.name as closer_name,
         r.office_name,
         r.region,
         r.metro_area,
         r.lead_gen_fdc_percent,
         r.self_gen_fdc,
         r.total_fdc,
         rank() OVER (ORDER BY r.total_fdc DESC) as rank,
         CASE
             WHEN COUNT(*) OVER (PARTITION BY r.total_fdc) > 1 THEN 'T' || rank() OVER (ORDER BY r.total_fdc DESC)
             ELSE rank() OVER (ORDER BY r.total_fdc DESC)::text
             END AS rank_label
  from results r
  order by r.total_fdc desc;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
