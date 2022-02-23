CREATE OR REPLACE FUNCTION brs.rpt_company_dashboard(p_custom_start_date date, p_custom_end_date date,
                                                     p_company_id integer,
                                                     p_target_type_id integer default -1) -- if p_target_type_id = 1 then it's a single day
-- if p_target_type_id > 1 then use dates for target
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_target_start_date date;
  v_company_id        integer;
BEGIN
  v_target_start_date = p_custom_start_date;
  if p_target_type_id = 1 then
    select date_trunc('week', p_custom_start_date)::date
    into v_target_start_date;
  end if;
  v_company_id = p_company_id;
  if p_company_id = 2 then
    v_company_id = 3;
  end if;
  RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
               from (
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'First Time Appointments Created' as name,
                                    1                                 as milestone_type_id,
                                    1                                 as display_order,
                                    (select count(1) as company_count
                                     from brs.project_details pd
                                      inner join flow.project_process_step_event ppse on ppse.id = pd.first_appointment_ppse_id
                                     where ((ppse.scheduled_date at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                                 as company_count,
                                    0                                 as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as company_count
--                                          from brs.project_details pd
--                                                 inner join first_appointment fa on fa.project_id = pd.project_id
--                                          where ((fa.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end                      as partner_count,
                                    0                                 as brs_target,
                                    0                                 as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Planned Appointments' as name,
                                    2                      as milestone_type_id,
                                    2                      as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                      as company_count,
                                    0                      as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end           as partner_count,
                                    0                      as brs_target,
                                    0                      as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             true  as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Pitches' as name,
                                    3         as milestone_type_id,
                                    3         as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.first_appointment_pitched at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )         as company_count,
                                    0         as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.first_appointment_pitched at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end as partner_count,
                                    0         as brs_target,
                                    0         as partner_target
                           ) as row_counts
                      union
                      select name,
                             true  as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Bookings'   as name,
                                    4            as milestone_type_id,
                                    4            as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.installation_agreement_signed_date at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )            as company_count,
                                    0            as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.installation_agreement_signed_date at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end as partner_count,
                                    case
                                      when p_target_type_id > 0 then
                                        (select coalesce(bookings_brs, 0)
                                         from brs.company_dashboard_targets
                                         where target_date = v_target_start_date)
                                      else 0 end as brs_target,
                                    case
                                      when p_target_type_id > 0 then
                                        (select coalesce(bookings_partner, 0)
                                         from brs.company_dashboard_targets
                                         where target_date = v_target_start_date)
                                      else 0 end as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Site Surveys Verified' as name,
                                    5                       as milestone_type_id,
                                    5                       as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.site_survey_verified_date at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                       as company_count,
                                    0                       as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.site_survey_verified_date at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end            as partner_count,
                                    0                       as brs_target,
                                    0                       as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Final Designs Created' as name,
                                    6                       as milestone_type_id,
                                    6                       as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.final_design_created_timestamp at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                       as company_count,
                                    0                       as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.final_design_created_timestamp at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end            as partner_count,
                                    0                       as brs_target,
                                    0                       as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Final Designs Sent' as name,
                                    7                    as milestone_type_id,
                                    7                    as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                    as company_count,
                                    0                    as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end         as partner_count,
                                    0                    as brs_target,
                                    0                    as partner_target
                           ) as row_counts
                      union
                      select name,
                             true  as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Final Designs Approved' as name,
                                    8                        as milestone_type_id,
                                    8                        as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.final_design_signed_date at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                        as company_count,
                                    0                        as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.final_design_signed_date at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end             as partner_count,
                                    0                        as brs_target,
                                    0                        as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Final Designs Completed' as name,
                                    9                         as milestone_type_id,
                                    9                         as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.final_design_complete_date at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                         as company_count,
                                    0                         as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.final_design_complete_date at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end              as partner_count,
                                    case
                                      when p_target_type_id > 0 then
                                        (select coalesce(final_designs_completed_brs, 0)
                                         from brs.company_dashboard_targets
                                         where target_date = v_target_start_date)
                                      else 0 end              as brs_target,
                                    case
                                      when p_target_type_id > 0 then
                                        (select coalesce(final_designs_completed_brs, 0)
                                         from brs.company_dashboard_targets
                                         where target_date = v_target_start_date)
                                      else 0 end              as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Plan Sets Created' as name,
                                    10                  as milestone_type_id,
                                    10                  as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.plan_set_created_date at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                   as company_count,
                                    0                   as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.plan_set_created_date at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end        as partner_count,
                                    0                   as brs_target,
                                    0                   as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Permit Packs Created' as name,
                                    11                     as milestone_type_id,
                                    11                     as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.permit_pack_complete at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                      as company_count,
                                    0                      as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.permit_pack_complete at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end           as partner_count,
                                    0                      as brs_target,
                                    0                      as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Permits Submitted' as name,
                                    12                  as milestone_type_id,
                                    12                  as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd

                                     where least(
                                       ((pd.online_submission_time at time zone 'UTC') at time zone 'US/Mountain'),
                                       permit_pack_submittal_verified_date) :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                   as company_count,
                                    0                   as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where least(
--                                              ((pd.online_submission_time at time zone 'UTC') at time zone 'US/Mountain'),
--                                              permit_pack_submittal_verified_date) :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end        as partner_count,
                                    0                   as brs_target,
                                    0                   as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Permits Approved' as name,
                                    13                 as milestone_type_id,
                                    13                 as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.permit_approved_date at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                  as company_count,
                                    0                  as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.permit_approved_date at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end       as partner_count,
                                    0                  as brs_target,
                                    0                  as partner_target
                           ) as row_counts
                      union
                      select name,
                             true as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Installations Made Ready to Schedule' as name,
                                    22                                     as milestone_type_id,
                                    14                                     as display_order,
                                    (with results as (
                                      SELECT p.id,
                                             min((wqc.date_entered_queue AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::date as date_entered_queue
                                      FROM flow.work_queue_cycle wqc
                                             inner join flow.project_process_step pps ON wqc.project_process_step_id = pps.id
                                             inner join flow.company_process_step_status_type cpsst
                                                        ON wqc.company_process_step_status_type_id = cpsst.id
                                             inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                                                        ON wqc.process_step_work_queue_type_process_step_status_type_id =
                                                           pswqtpsst.id
                                             inner join flow.process_step_work_queue_type pswqt
                                                        ON pswqtpsst.process_step_work_queue_type_id = pswqt.id
                                             inner join flow.user u on u.id = pps.created_by_id
                                             JOIN flow.work_queue_type wqt ON pswqt.work_queue_type_id = wqt.id
                                             inner join flow.project p ON pps.project_id = p.id
                                      WHERE pps.process_step_id = 3365
                                        AND work_queue_type_id = 93
                                      group by p.id
                                    )
                                     select count(1) as count
                                     from results
                                     where date_entered_queue between p_custom_start_date and p_custom_end_date
                                    )                                      as company_count,
                                    0                                      as partner_count,
                                    0                                      as brs_target,
                                    0                                      as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Installations Scheduled' as name,
                                    14                        as milestone_type_id,
                                    15                        as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.installation_scheduled at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                         as company_count,
                                    0                         as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.installation_scheduled at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end              as partner_count,
                                    0                         as brs_target,
                                    0                         as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             true  as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Planned Installations' as name,
                                    15                      as milestone_type_id,
                                    16                      as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where (
                                         ((pd.installation_start_time at time zone 'UTC') at time zone 'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date or
                                         ((pd.installation_closeout_start_time at time zone 'UTC') at time zone
                                          'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date)
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                       as company_count,
                                    0                       as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where (
--                                              ((pd.installation_start_time at time zone 'UTC') at time zone 'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date or
--                                              ((pd.installation_closeout_start_time at time zone 'UTC') at time zone
--                                               'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date)
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end            as partner_count,
                                    0                       as brs_target,
                                    0                       as partner_target
                           ) as row_counts
                      union
                      select name,
                             true  as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Substantial Completions' as name,
                                    16                        as milestone_type_id,
                                    17                        as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.substantial_completion_date at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                         as company_count,
                                    0                         as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.substantial_completion_date at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end              as partner_count,
                                    case
                                      when p_target_type_id > 0 then
                                        (select coalesce(substantial_completions_brs, 0)
                                         from brs.company_dashboard_targets
                                         where target_date = v_target_start_date)
                                      else 0 end              as brs_target,
                                    case
                                      when p_target_type_id > 0 then
                                        (select coalesce(substantial_completions_partner, 0)
                                         from brs.company_dashboard_targets
                                         where target_date = v_target_start_date)
                                      else 0 end              as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             true  as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Inspections Scheduled' as name,
                                    17                      as milestone_type_id,
                                    18                      as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where (
                                         pd.ahj_inspection_scheduled_date BETWEEN p_custom_start_date and p_custom_end_date or
                                         pd.ahj_reinspection_scheduled_date BETWEEN p_custom_start_date and p_custom_end_date)
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                       as company_count,
                                    0                       as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where (
--                                              pd.ahj_inspection_scheduled_date BETWEEN p_custom_start_date and p_custom_end_date or
--                                              pd.ahj_reinspection_scheduled_date BETWEEN p_custom_start_date and p_custom_end_date)
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end            as partner_count,
                                    0                       as brs_target,
                                    0                       as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             true  as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Planned Inspections' as name,
                                    18                    as milestone_type_id,
                                    19                    as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where (((pd.ahj_inspection_start_time at time zone 'UTC') at time zone
                                             'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date or
                                            ((pd.ahj_reinspection_start_time at time zone 'UTC') at time zone
                                             'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date)
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                     as company_count,
                                    0                     as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where (((pd.ahj_inspection_start_time at time zone 'UTC') at time zone
--                                                  'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date or
--                                                 ((pd.ahj_reinspection_start_time at time zone 'UTC') at time zone
--                                                  'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date)
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end          as partner_count,
                                    0                     as brs_target,
                                    0                     as partner_target
                           ) as row_counts
                      union
                      select name,
                             true  as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Inspections Passed' as name,
                                    19                   as milestone_type_id,
                                    20                   as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where ((pd.ahj_final_inspection_verified at time zone 'UTC') at time zone
                                            'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                    as company_count,
                                    0                    as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where ((pd.ahj_final_inspection_verified at time zone 'UTC') at time zone
--                                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end         as partner_count,
                                    0                    as brs_target,
                                    0                    as partner_target
                           ) as row_counts
                      union
                      select name,
                             false as show_targets,
                             true  as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Inspection Results Submitted' as name,
                                    20                             as milestone_type_id,
                                    21                             as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where (
                                         pd.verified_inspection_approval_received_by_utility_date BETWEEN p_custom_start_date and p_custom_end_date
                                         or
                                         pd.ahj_inspection_approval_submitted_date BETWEEN p_custom_start_date and p_custom_end_date)
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                              as company_count,
                                    0                              as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where (
--                                              pd.verified_inspection_approval_received_by_utility_date BETWEEN p_custom_start_date and p_custom_end_date
--                                              or
--                                              pd.ahj_inspection_approval_submitted_date BETWEEN p_custom_start_date and p_custom_end_date)
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end                   as partner_count,
                                    0                              as brs_target,
                                    0                              as partner_target
                           ) as row_counts
                      union
                      select name,
                             true  as show_targets,
                             false as has_additional_column,
                             milestone_type_id,
                             display_order,
                             company_count,
                             partner_count,
                             brs_target,
                             partner_target

                      from (
                             select 'Final Completions' as name,
                                    21                  as milestone_type_id,
                                    22                  as display_order,
                                    (select count(1) as count
                                     from brs.project_details pd
                                     where pd.final_completion_submitted_date BETWEEN p_custom_start_date and p_custom_end_date
                                       and pd.company_id = v_company_id
                                       and pd.archived is false
                                    )                   as company_count,
                                    0                   as partner_count,
--                                     case
--                                       when p_company_id = 2 then
--                                         (select count(1) as count
--                                          from brs.project_details pd
--                                          where pd.final_completion_submitted_date BETWEEN p_custom_start_date and p_custom_end_date
--                                            and pd.company_id != 3
--                                            and pd.archived is false
--                                         )
--                                       else 0 end        as partner_count,
                                    case
                                      when p_target_type_id > 0 then
                                        (select coalesce(final_completions_brs, 0)
                                         from brs.company_dashboard_targets
                                         where target_date = v_target_start_date)
                                      else 0 end        as brs_target,
                                    case
                                      when p_target_type_id > 0 then
                                        (select coalesce(final_completions_partner, 0)
                                         from brs.company_dashboard_targets
                                         where target_date = v_target_start_date)
                                      else 0 end        as partner_target
                           ) as row_counts
                      order by display_order
                    ) as funnel_rows;


END
$function$
