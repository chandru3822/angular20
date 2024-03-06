drop function if exists brs.rpt_company_dashboard(p_custom_start_date date, p_custom_end_date date,
                                                  p_company_id bigint,
                                                  p_target_type_id bigint,
                                                  p_run_by_id bigint);
drop function if exists brs.rpt_company_dashboard(p_custom_start_date date, p_custom_end_date date,
                                                  p_trend_start_date date, p_trend_end_date date);
CREATE OR REPLACE FUNCTION brs.rpt_company_dashboard(p_custom_start_date date, p_custom_end_date date,
                                                     p_trend_start_date date default null, p_trend_end_date date default null)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
BEGIN
  RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
               from (
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                                 as milestone_type_id,
                                    dm.display_order                                 as display_order,
                                    (select sum(cddm.first_time_appointment_created)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.first_time_appointment_created)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 1
                           ) as row_counts

                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                      as milestone_type_id,
                                    dm.display_order                      as display_order,
                                    (select sum(cddm.planned_appointments)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.planned_appointments)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone

                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 2


                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id         as milestone_type_id,
                                    dm.display_order         as display_order,
                                    (select sum(cddm.pitches)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.pitches)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 3

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id            as milestone_type_id,
                                    dm.display_order            as display_order,
                                    (select sum(cddm.bookings)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.bookings)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 4

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                       as milestone_type_id,
                                    dm.display_order                       as display_order,
                                    (select sum(cddm.site_surveys_verified)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.site_surveys_verified)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 5

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                       as milestone_type_id,
                                    dm.display_order                       as display_order,
                                    (select sum(cddm.final_designs_created)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.final_designs_created)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 6

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                    as milestone_type_id,
                                    dm.display_order                    as display_order,
                                    (select sum(cddm.final_designs_sent)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.final_designs_sent)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 7

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                        as milestone_type_id,
                                    dm.display_order                        as display_order,
                                    (select sum(cddm.final_designs_approved)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.final_designs_approved)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 8

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                         as milestone_type_id,
                                    dm.display_order                         as display_order,
                                    (select sum(cddm.final_designs_completed)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.final_designs_completed)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 9

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                  as milestone_type_id,
                                    dm.display_order                  as display_order,
                                    (select sum(cddm.plan_sets_created)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.plan_sets_created)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 10

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                     as milestone_type_id,
                                    dm.display_order                     as display_order,
                                    (select sum(cddm.permit_packs_created)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.permit_packs_created)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 11

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                  as milestone_type_id,
                                    dm.display_order                  as display_order,
                                    (select sum(cddm.permits_submitted)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.permits_submitted)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 12

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                 as milestone_type_id,
                                    dm.display_order                 as display_order,
                                    (select sum(cddm.permits_approved)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.permits_approved)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 13

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                                     as milestone_type_id,
                                    dm.display_order                                     as display_order,
                                    (select sum(cddm.installations_made_ready_to_schedule)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.installations_made_ready_to_schedule)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 22

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                        as milestone_type_id,
                                    dm.display_order                        as display_order,
                                    (select sum(cddm.installations_scheduled)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.installations_scheduled)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 14

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                      as milestone_type_id,
                                    dm.display_order                      as display_order,
                                    (select sum(cddm.planned_installations)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.planned_installations)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 15

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                        as milestone_type_id,
                                    dm.display_order                        as display_order,
                                    (select sum(cddm.substantial_completions)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.substantial_completions)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 16

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                      as milestone_type_id,
                                    dm.display_order                      as display_order,
                                    (select sum(cddm.inspections_scheduled)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.inspections_scheduled)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 17

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                    as milestone_type_id,
                                    dm.display_order                    as display_order,
                                    (select sum(cddm.planned_inspections)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.planned_inspections)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 18

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                   as milestone_type_id,
                                    dm.display_order                   as display_order,
                                    (select sum(cddm.inspections_passed)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.inspections_passed)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 19

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                             as milestone_type_id,
                                    dm.display_order                             as display_order,
                                    (select sum(cddm.inspection_results_submitted)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.inspection_results_submitted)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 20

                           ) as row_counts
                      union
                      select name,
                             milestone_type_id,
                             display_order,
                             company_count,
                             case when trend_count is not null then
                                    round((company_count::numeric - trend_count::numeric)/greatest(trend_count::numeric,1) * 100)::numeric end as trend_count,
                             major_milestone

                      from (
                             select dm.name as name,
                                    dm.id                  as milestone_type_id,
                                    dm.display_order                  as display_order,
                                    (select sum(cddm.final_completions)
                                     from brs.company_dashboard_daily_metric cddm
                                     where cddm.metric_date between p_custom_start_date and p_custom_end_date )as company_count,
                                    case when p_trend_start_date is not null then
                                           (select sum(cddm.final_completions)
                                            from brs.company_dashboard_daily_metric cddm
                                            where cddm.metric_date between p_trend_start_date and p_trend_end_date ) end as trend_count,
                                    dm.major_milestone
                             from  brs.dashboard_milestone dm
                                     inner join brs.dashboard_milestone_type dmt on dmt.id = dm.dashboard_milestone_type_id and dmt.dashboard_milestone_code = 'COMPANY_DASHBOARD'
                             where dm.id = 21

                           ) as row_counts
                      order by display_order
                    ) as funnel_rows;


END
$function$
