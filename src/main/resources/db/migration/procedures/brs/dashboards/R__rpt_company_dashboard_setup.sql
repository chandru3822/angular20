drop procedure if exists brs.rpt_company_dashboard_setup(p_start_time timestamp);
CREATE OR REPLACE procedure brs.rpt_company_dashboard_setup(p_start_time timestamp default now()- interval '3 months')
AS
$BODY$
declare
  x                    record;
BEGIN

--   if p_start_time is null then
--
--     select min(my_date)
--     into v_start_time
--     from (select least(((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        first_appointment,
--                        ((pd.first_appointment_pitched at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        first_appointment_pitched,
--                        pd.installation_agreement_signed_date,
--                        pd.site_survey_verified_date,
--                        ((pd.final_design_created_timestamp at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        final_design_created_timestamp,
--                        ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        final_design_sent_to_homeowner_date,
--                        pd.final_design_signed_date,
--                        pd.final_design_complete_date,
--                        pd.plan_set_created_date,
--                        pd.permit_pack_complete,
--                        ((pd.online_submission_time at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        online_submission_time,
--                        pd.permit_pack_submittal_verified_date,
--                        pd.permit_approved_date,
--                        pd.installation_scheduled,
--                        ((pd.installation_start_time at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        installation_start_time,
--                        ((pd.installation_closeout_start_time at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        installation_closeout_start_time,
--                        pd.substantial_completion_date,
--                        pd.ahj_inspection_scheduled_date,
--                        pd.ahj_reinspection_scheduled_date,
--                        ((pd.ahj_inspection_start_time at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        ahj_inspection_start_time,
--                        ((pd.ahj_reinspection_start_time at time zone 'UTC') at time zone 'US/Mountain')::date as
--                        ahj_reinspection_start_time,
--                        pd.ahj_final_inspection_verified,
--                        pd.verified_inspection_approval_received_by_utility_date,
--                        pd.ahj_inspection_approval_submitted_date,
--                        pd.final_completion_submitted_date) as my_date
--           from brs.project_details pd
--           where pd.date_modified >= v_last_modified_date) as foo;
--   end if;

  for x in select generate_series(p_start_time,
                                  now(), interval '1 day')::date as metric_date
    loop

      insert into brs.company_dashboard_daily_metric(metric_date,
                                                     first_time_appointment_created,
                                                     planned_appointments,
                                                     pitches,
                                                     bookings,
                                                     site_surveys_verified,
                                                     final_designs_created,
                                                     final_designs_sent,
                                                     final_designs_approved,
                                                     final_designs_completed,
                                                     plan_sets_created,
                                                     permit_packs_created,
                                                     permits_submitted,
                                                     permits_approved,
                                                     installations_made_ready_to_schedule,
                                                     installations_scheduled,
                                                     planned_installations,
                                                     substantial_completions,
                                                     inspections_scheduled,
                                                     planned_inspections,
                                                     inspections_passed,
                                                     inspection_results_submitted,
                                                     final_completions)
      values (x.metric_date,
              (select count(*) as count
               from brs.project_details as pd
               where ((pd.first_time_appointment_created at time zone 'UTC') at time zone 'US/Mountain') ::date =
                     x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details as pd
               where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') ::date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where ((pd.first_appointment_pitched at time zone 'UTC') at time zone
                      'US/Mountain') :: date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.installation_agreement_signed_date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.site_survey_verified_date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where ((pd.final_design_created_timestamp at time zone 'UTC') at time zone
                      'US/Mountain') :: date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                      'US/Mountain') :: date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.final_design_signed_date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.final_design_complete_date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.plan_set_created_date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.permit_pack_complete = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where permit_pack_submission_date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.permit_approved_date = x.metric_date
                 and pd.archived is false),
              (with results as (SELECT pps.project_id,
                                       min((wqc.date_entered_queue AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::date as date_entered_queue
                                FROM flow.work_queue_cycle wqc
                                       inner join flow.project_process_step pps ON wqc.project_process_step_id = pps.id
                                       inner join flow.company_process_step_status_type cpsst
                                                  ON wqc.company_process_step_status_type_id = cpsst.id
                                       inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                                                  ON
                                                    wqc.process_step_work_queue_type_process_step_status_type_id =
                                                    pswqtpsst.id
                                       inner join flow.process_step_work_queue_type pswqt
                                                  ON pswqtpsst.process_step_work_queue_type_id = pswqt.id
                                  --                                            inner join flow.user u on u.id = pps.created_by_id
--                                            JOIN flow.work_queue_type wqt ON pswqt.work_queue_type_id = wqt.id
                                  -- this project line needs to be here in order to filter out archived projects. but is otherwise useless
                                       inner join flow.project p ON pps.project_id = p.id and p.archived is false
                                WHERE pps.process_step_id = 3365
                                  and pps.archived is false
                                  AND work_queue_type_id = 93
                                group by pps.project_id)
               select count(*) as count
               from results
               where date_entered_queue = x.metric_date),
              (select count(*) as count
               from brs.project_details pd
               where pd.installation_scheduled = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where (
                 ((pd.installation_start_time at time zone 'UTC') at time zone 'US/Mountain') :: date = x.metric_date or
                 ((pd.installation_closeout_start_time at time zone 'UTC') at time zone
                  'US/Mountain') :: date = x.metric_date)
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.substantial_completion_date = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where (
                 pd.ahj_inspection_scheduled_date = x.metric_date or
                 pd.ahj_reinspection_scheduled_date = x.metric_date)
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where (((pd.ahj_inspection_start_time at time zone 'UTC') at time zone
                       'US/Mountain') :: date = x.metric_date or
                      ((pd.ahj_reinspection_start_time at time zone 'UTC') at time zone
                       'US/Mountain') :: date = x.metric_date)
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.ahj_final_inspection_verified = x.metric_date
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where (
                 pd.verified_inspection_approval_received_by_utility_date = x.metric_date
                   or
                 pd.ahj_inspection_approval_submitted_date = x.metric_date)
                 and pd.archived is false),
              (select count(*) as count
               from brs.project_details pd
               where pd.final_completion_submitted_date = x.metric_date
                 and pd.archived is false))
      ON CONFLICT (metric_date) DO UPDATE
        SET first_time_appointment_created       = (select count(*) as count
                                                    from brs.project_details as pd
                                                    where
                                                      ((pd.first_time_appointment_created at time zone 'UTC') at time zone
                                                       'US/Mountain') ::date =
                                                      x.metric_date
                                                      and pd.archived is false),
            planned_appointments                 = (select count(*) as count
                                                    from brs.project_details as pd
                                                    where
                                                      ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') ::date =
                                                      x.metric_date
                                                      and pd.archived is false),
            pitches                              = (select count(*) as count
                                                    from brs.project_details pd
                                                    where
                                                      ((pd.first_appointment_pitched at time zone 'UTC') at time zone
                                                       'US/Mountain') :: date = x.metric_date
                                                      and pd.archived is false),
            bookings                             = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.installation_agreement_signed_date = x.metric_date
                                                      and pd.archived is false),
            site_surveys_verified                = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.site_survey_verified_date = x.metric_date
                                                      and pd.archived is false),
            final_designs_created                = (select count(*) as count
                                                    from brs.project_details pd
                                                    where
                                                      ((pd.final_design_created_timestamp at time zone 'UTC') at time zone
                                                       'US/Mountain') :: date = x.metric_date
                                                      and pd.archived is false),
            final_designs_sent                   = (select count(*) as count
                                                    from brs.project_details pd
                                                    where
                                                      ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                                       'US/Mountain') :: date = x.metric_date
                                                      and pd.archived is false),
            final_designs_approved               = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.final_design_signed_date = x.metric_date
                                                      and pd.archived is false),
            final_designs_completed              = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.final_design_complete_date = x.metric_date
                                                      and pd.archived is false),
            plan_sets_created                    = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.plan_set_created_date = x.metric_date
                                                      and pd.archived is false),
            permit_packs_created                 = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.permit_pack_complete = x.metric_date
                                                      and pd.archived is false),
            permits_submitted                    = (select count(*) as count
                                                    from brs.project_details pd
                                                    where permit_pack_submission_date =
                                                          x.metric_date
                                                      and pd.archived is false),
            permits_approved                     = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.permit_approved_date = x.metric_date
                                                      and pd.archived is false),
            installations_made_ready_to_schedule = (with results as (SELECT pps.project_id,
                                                                            min((wqc.date_entered_queue AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::date as date_entered_queue
                                                                     FROM flow.work_queue_cycle wqc
                                                                            inner join flow.project_process_step pps ON wqc.project_process_step_id = pps.id
                                                                            inner join flow.company_process_step_status_type cpsst
                                                                                       ON wqc.company_process_step_status_type_id = cpsst.id
                                                                            inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                                                                                       ON
                                                                                         wqc.process_step_work_queue_type_process_step_status_type_id =
                                                                                         pswqtpsst.id
                                                                            inner join flow.process_step_work_queue_type pswqt
                                                                                       ON pswqtpsst.process_step_work_queue_type_id = pswqt.id
                                                                       --                                            inner join flow.user u on u.id = pps.created_by_id
--                                            JOIN flow.work_queue_type wqt ON pswqt.work_queue_type_id = wqt.id
                                                                       -- this project line needs to be here in order to filter out archived projects. but is otherwise useless
                                                                            inner join flow.project p ON pps.project_id = p.id and p.archived is false
                                                                     WHERE pps.process_step_id = 3365
                                                                       and pps.archived is false
                                                                       AND work_queue_type_id = 93
                                                                     group by pps.project_id)
                                                    select count(*) as count
                                                    from results
                                                    where date_entered_queue = x.metric_date),
            installations_scheduled              = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.installation_scheduled = x.metric_date
                                                      and pd.archived is false),
            planned_installations                = (select count(*) as count
                                                    from brs.project_details pd
                                                    where (
                                                      ((pd.installation_start_time at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                      x.metric_date or
                                                      ((pd.installation_closeout_start_time at time zone 'UTC') at time zone
                                                       'US/Mountain') :: date = x.metric_date)
                                                      and pd.archived is false),
            substantial_completions              = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.substantial_completion_date = x.metric_date
                                                      and pd.archived is false),
            inspections_scheduled                = (select count(*) as count
                                                    from brs.project_details pd
                                                    where (
                                                      pd.ahj_inspection_scheduled_date = x.metric_date or
                                                      pd.ahj_reinspection_scheduled_date = x.metric_date)
                                                      and pd.archived is false),
            planned_inspections                  = (select count(*) as count
                                                    from brs.project_details pd
                                                    where (
                                                      ((pd.ahj_inspection_start_time at time zone 'UTC') at time zone
                                                       'US/Mountain') :: date = x.metric_date or
                                                      ((pd.ahj_reinspection_start_time at time zone 'UTC') at time zone
                                                       'US/Mountain') :: date = x.metric_date)
                                                      and pd.archived is false),
            inspections_passed                   = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.ahj_final_inspection_verified = x.metric_date
                                                      and pd.archived is false),
            inspection_results_submitted         = (select count(*) as count
                                                    from brs.project_details pd
                                                    where (
                                                      pd.verified_inspection_approval_received_by_utility_date =
                                                      x.metric_date
                                                        or
                                                      pd.ahj_inspection_approval_submitted_date =
                                                      x.metric_date)
                                                      and pd.archived is false),
            final_completions                    = (select count(*) as count
                                                    from brs.project_details pd
                                                    where pd.final_completion_submitted_date = x.metric_date
                                                      and pd.archived is false);
      commit;
    end loop;
  commit;
END
$BODY$
  LANGUAGE plpgsql;



