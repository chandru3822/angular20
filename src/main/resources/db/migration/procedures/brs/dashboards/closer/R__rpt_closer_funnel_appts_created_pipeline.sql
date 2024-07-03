drop function if exists brs.rpt_closer_funnel_appts_created_pipeline(p_custom_start_date date,
                                                                     p_custom_end_date date,
                                                                     p_brs_provided_source_ids bigint[],
                                                                     p_self_gen_source_ids bigint[],
                                                                     p_run_by_id bigint);
drop function if exists brs.rpt_closer_funnel_appts_created_pipeline(p_custom_start_date date,
                                                                        p_custom_end_date date,
                                                                        p_trend_start_date date,
                                                                        p_trend_end_date date,
                                                                        p_brs_provided_source_ids bigint[],
                                                                        p_self_gen_source_ids bigint[],
                                                                        p_lead_created_source_ids bigint[]);

CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appts_created_pipeline(p_custom_start_date date,
                                                                        p_custom_end_date date,
                                                                        p_trend_start_date date,
                                                                        p_trend_end_date date,
                                                                        p_brs_provided_source_ids bigint[],
                                                                        p_self_gen_source_ids bigint[],
                                                                        p_lead_created_source_ids bigint[])
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
BEGIN
-- raise notice 'p_brs_provided_source_ids %',p_brs_provided_source_ids;
-- raise notice 'p_self_gen_source_ids %',p_self_gen_source_ids;
  RETURN QUERY
    select array_to_json(array_agg(row_to_json(funnel_rows)))
    from (with leads_created as (select id,
                                        name,
                                        display_order,
                                        leads_created_count,
                                        leads_created_trend_count,
                                        case
                                          when leads_created_trend_count is not null then
                                            round((leads_created_count - leads_created_trend_count)::numeric /
                                                  greatest(leads_created_trend_count, 1) * 100)::numeric end as trend
                                 from (select f.id,
                                              f.name,
                                              f.display_order,
                                              (select count(1)
                                               from flow.contact c
                                               inner join flow.contact_custom_field_value ccfv on ccfv.contact_id = c.id and
                                                                                                 custom_field_group_assignment_id = 395 and
                                                                                                 ccfv.int_value = any(p_lead_created_source_ids)
                                               where c.company_id = 3
                                                 and ((c.date_created at time zone 'UTC') at time zone
                                                      'US/Mountain')::date between p_custom_start_date and p_custom_end_date) as leads_created_count,
                                              case
                                                when p_trend_start_date is not null then
                                                  (select count(1)
                                                   from flow.contact c2
                                                          inner join flow.contact_custom_field_value ccfv on ccfv.contact_id = c2.id and
                                                                                                            custom_field_group_assignment_id = 395 and
                                                                                                            ccfv.int_value = any(p_lead_created_source_ids)
                                                   where c2.company_id = 3
                                                     and ((c2.date_created at time zone 'UTC') at time zone
                                                          'US/Mountain')::date between p_trend_start_date and p_trend_end_date)
                                                else 0 end                                                                    as leads_created_trend_count
                                       from brs.funnel f
                                       where archived is false
                                         and funnel_type_id = 2
                                         and f.id = 34) as foo),

               brs_gen_counts as (select id,
                                         name,
                                         display_order,
                                         brs_gen_count,
                                         brs_gen_trend_count,
                                         case
                                           when brs_gen_trend_count is not null then
                                             round((brs_gen_count - brs_gen_trend_count)::numeric /
                                                   greatest(brs_gen_trend_count, 1) *
                                                   100)::numeric end as trend
                                  from (select f.id,
                                               f.name,
                                               f.display_order,
                                               (select count(1)
                                                from brs.project_details pd
                                                where pd.company_id = 3
                                                  and pd.first_time_appointment_created is not null
                                                  and pd.closer_user_id is not null
                                                  and pd.source = any (p_brs_provided_source_ids)
                                                  and (
                                                  (pd.first_time_appointment_created at time zone 'UTC') at time zone
                                                  'US/Mountain')::date between p_custom_start_date and p_custom_end_date) as brs_gen_count,
                                               case
                                                 when p_trend_start_date is not null then
                                                   (select count(1)
                                                    from brs.project_details pd
                                                    where pd.company_id = 3
                                                      and pd.first_time_appointment_created is not null
                                                      and pd.closer_user_id is not null
                                                      and pd.source = any (p_brs_provided_source_ids)
                                                      and (
                                                      (pd.first_time_appointment_created at time zone 'UTC') at time zone
                                                      'US/Mountain')::date between p_trend_start_date and p_trend_end_date)
                                                 else 0 end                                                               as brs_gen_trend_count
                                        from brs.funnel f
                                        where archived is false
                                          and funnel_type_id = 2
                                          and f.id = 12) as foo),
               self_gen_counts as (select id,
                                          name,
                                          display_order,
                                          self_gen_count,
                                          self_gen_trend_count,
                                          case
                                            when self_gen_trend_count is not null then
                                              round(
                                                (self_gen_count - self_gen_trend_count)::numeric /
                                                greatest(self_gen_trend_count, 1) *
                                                100)::numeric end as trend
                                   from (select f.id,
                                                f.name,
                                                f.display_order,
                                                (select count(1)
                                                 from brs.project_details pd
                                                 where pd.company_id = 3
                                                   and pd.first_time_appointment_created is not null
                                                   and pd.closer_user_id is not null
                                                   and pd.source = any (p_self_gen_source_ids)
                                                   and (
                                                   (pd.first_time_appointment_created at time zone 'UTC') at time zone
                                                   'US/Mountain')::date between p_custom_start_date and p_custom_end_date) as self_gen_count,
                                                case
                                                  when p_trend_start_date is not null then
                                                    (select count(1)
                                                     from brs.project_details pd
                                                     where pd.company_id = 3
                                                       and pd.first_time_appointment_created is not null
                                                       and pd.closer_user_id is not null
                                                       and pd.source = any (p_self_gen_source_ids)
                                                       and (
                                                       (pd.first_time_appointment_created at time zone 'UTC') at time zone
                                                       'US/Mountain')::date between p_trend_start_date and p_trend_end_date)
                                                  else 0 end                                                               as self_gen_trend_count
                                         from brs.funnel f
                                         where archived is false
                                           and funnel_type_id = 2
                                           and f.id = 13) as foo),


               missed_counts as (select id,
                                        name,
                                        display_order,
                                        missed_count,
                                        missed_trend_count,
                                        case
                                          when missed_trend_count is not null then
                                            round(
                                              (missed_count - missed_trend_count)::numeric / greatest(missed_trend_count, 1) *
                                              100)::numeric end as trend
                                 from (select f.id,
                                              f.name,
                                              f.display_order,
                                              (select count(1)
                                               from brs.project_details pd
                                               where pd.company_id = 3
                                                 and pd.first_time_appointment_created is not null
                                                 and pd.closer_user_id is not null
                                                 and pd.source is null
                                                 and (
                                                 (pd.first_time_appointment_created at time zone 'UTC') at time zone
                                                 'US/Mountain')::date between p_custom_start_date and p_custom_end_date) as missed_count,
                                              case
                                                when p_trend_start_date is not null then
                                                  (select count(1)
                                                   from brs.project_details pd
                                                   where pd.company_id = 3
                                                     and pd.first_time_appointment_created is not null
                                                     and pd.closer_user_id is not null
                                                     and pd.source is null
                                                     and (
                                                     (pd.first_time_appointment_created at time zone 'UTC') at time zone
                                                     'US/Mountain')::date between p_trend_start_date and p_trend_end_date)
                                                else 0 end                                                               as missed_trend_count
                                       from brs.funnel f
                                       where archived is false
                                         and funnel_type_id = 2
                                         and f.id = 26) as foo)
          select *
          from leads_created lc
          union
          select *
          from brs_gen_counts
          union
          select *
          from self_gen_counts
          union
          select *
          from missed_counts
          union
          select *,
                 case
                   when total_trend_count is not null then
                     round((total_count - total_trend_count)::numeric / greatest(total_trend_count, 1) *
                           100)::numeric end as trend
          from (select f2.id,
                       f2.name,
                       f2.display_order,
                       bgc.brs_gen_count + sfc.self_gen_count + mc.missed_count                   as total_count,
                       bgc.brs_gen_trend_count + sfc.self_gen_trend_count + mc.missed_trend_count as total_trend_count
                from brs.funnel f2
                       cross join brs_gen_counts bgc
                       cross join self_gen_counts sfc
                       cross join missed_counts mc
                where f2.id = 10) as foo
          order by 3) as funnel_rows;


END
$function$
