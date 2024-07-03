drop function if exists brs.get_closer_org_rankings(p_time_interval bigint);
drop function if exists brs.get_closer_org_rankings(date,date);
CREATE OR REPLACE FUNCTION brs.get_closer_org_rankings(p_start_date date,p_end_date date)
    RETURNS table
            (
                office_name             character varying,
                region                  character varying,
                metro_area              character varying,
                lead_gen_fdc_percentage numeric,
                self_gen_fdc            bigint,
                total_fdc               bigint,
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
             current_closers as (select distinct u.id,
                                                 up.id as user_position_id,
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
                                   -- AND up.primary_flag IS true
                                   and (up.end_date is null or
                                        up.end_date >= (now() at time zone 'US/Mountain')::date - (v_time_interval || 'day')::interval)
                                   AND ust.has_access is true)
                ,
             foo as (SELECT
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
                              left join LATERAL brs.get_fdc_counts(cc.id,cc.user_position_id, v_closer_gen_source_ids, v_time_interval) fdc_counts
                                        on true
                     GROUP BY cc.office_name, cc.region, cc.metro_area,
                              fdc_counts.lead_gen_fdc_count,
                              fdc_counts.lead_gen_appointment_count,
                              fdc_counts.self_gen_fdc_count,
                              fdc_counts.total_fdc_count)
        , results as (
                 select
                     foo.office_name,
                     foo.region,
                     foo.metro_area,
                     case
                         when sum(foo.leadGenFdcPercentageDenominator) < 1 then
                             0
                         else
                             round(
                                         (sum(foo.leadGenFdcPercentageNumerator::numeric) /
                                          sum(foo.leadGenFdcPercentageDenominator::numeric))::numeric *
                                         100) end as lead_gen_fdc_percent,
                     sum(foo.selfGenFdc)::bigint as self_gen_fdc,
                     sum(foo.totalFdc)::bigint as total_fdc
                 from foo
                 group by foo.office_name, foo.region, foo.metro_area)
        select r.office_name,
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
