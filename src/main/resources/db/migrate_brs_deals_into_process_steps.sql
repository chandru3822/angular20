/*SCHEDULE CLOSER APPOINTMENT*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            1,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where appointment_date is null  AND originator_id = 1
       and d.current_stage_id not in  (1,2,3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') and
         (d.on_hold IS NULL OR d.on_hold = FALSE));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                1,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                added_on
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where appointment_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 1
         and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, timestamp_value,
                                                         int_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id in (5,6) then ((appointment_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                when p.custom_field_group_assignment_id = 25 then ((proposal_appointment_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 7 then d2.closer_user_id else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*CLOSER APPOINTMENT*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            2,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where appointment_date is not null
       and appointment_outcome is null
       and d.current_stage_id not in (1,2,3) AND originator_id = 1 AND
           (d.financier IS NULL OR d.financier != '["One Roof Energy"]') and
         (d.on_hold IS NULL OR d.on_hold = FALSE));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                2,
                (SELECT id FROM flow.company_process_step_status_type WHERE case when d.appointment_outcome not in ('Cancelled','Missed') then
                                                                                         process_step_status_type = 'Complete' else
                                                                                         process_step_status_type = 'Cancelled' end
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                appointment_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where appointment_date is not null
           and appointment_outcome is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 2
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         int_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 4 then (select id from flow.list_of_value where parent_id = 1
                                                 and name = d2.appointment_outcome) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*CREATE PROPOSAL*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            3,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where d.proposal_appointment_date is not null
       and ((d.proposal_status is not null and d.proposal_status != 'Complete') or
            (d.proposal_complete_date is null and d.proposal_status = 'Complete'))
       and (d.appointment_outcome is null or
            (d.appointment_outcome != 'Cancelled' and d.appointment_outcome != 'No Go'))
       AND originator_id = 1  AND originator_id = 1  and d.current_stage_id not in  (1,2,3) AND
           (d.financier IS NULL OR d.financier != '["One Roof Energy"]') and
         (d.on_hold IS NULL OR d.on_hold = FALSE));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                3,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                proposal_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where proposal_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 3
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,timestamp_value,
                                                         int_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 23 then ((d2.props_double_check AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 22 then ((d2.proposal_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 24 then (select id from flow.list_of_value where parent_id = 307
                                                                                                       and name = d2.proposal_status) end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*BOOKING*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            4,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where d.appointment_outcome = 'Pitched' and
           installation_agreement_signed_date is null
       AND originator_id = 1
       and d.current_stage_id not in  (1,2,3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') and
         (d.on_hold IS NULL OR d.on_hold = FALSE));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                4,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                installation_agreement_signed_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
           (installation_agreement_signed_date is not null)
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 4
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,
                                                         int_value,numeric_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 11 then ((installation_agreement_signed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
             when p.custom_field_group_assignment_id = 12 then ((financial_agreement_sent_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 62 then ((credit_decision_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
            when p.custom_field_group_assignment_id = 13 then ((agreement_signed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 26 then (select id from blueraven.user where (first_name||' '||last_name) = d2.introduction_call_completed_by and introduction_call_completed_by is not null limit 1)
                 when p.custom_field_group_assignment_id = 27 then d2.proposal_nbr::integer
                when p.custom_field_group_assignment_id = 14 then (select id from flow.list_of_value where parent_id = 140
                                                                                                       and name = d2.introduction_call)
                 when p.custom_field_group_assignment_id = 61 then (select id from flow.list_of_value where parent_id = 81
                                                                                                        and name = d2.credit_check)
                 when p.custom_field_group_assignment_id = 41 then (select id from flow.list_of_value where parent_id = 238
                                                                                                        and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 42 then d2.panel_quantity
                 when p.custom_field_group_assignment_id = 43 then d2.panel_watts
                 when p.custom_field_group_assignment_id = 44 then (select id from flow.list_of_value where parent_id = 143
                                                                                                        and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 460 then (select id from flow.list_of_value where parent_id = 720
                                                                                                        and name = d2.financier :: JSON #>> '{0}')
                 when p.custom_field_group_assignment_id = 461 then (select id from flow.list_of_value where parent_id = 331
                                                                                                         and name = d2.secondary_financier)
                when p.custom_field_group_assignment_id = 58 then (select id from flow.list_of_value where parent_id = 423
                                                                                                                        and name::integer = d2.loan_term)
                 when p.custom_field_group_assignment_id = 54 then d2.number_of_promotion_payments
                else null end,
            case when p.custom_field_group_assignment_id = 46 then d2.loan_amount
                when p.custom_field_group_assignment_id = 48 then d2.interest_rate
                 when p.custom_field_group_assignment_id = 49 then d2.total_system_price
                 when p.custom_field_group_assignment_id = 40 then d2.system_size
                 when p.custom_field_group_assignment_id = 50 then d2.referral_promotion_amount
                 when p.custom_field_group_assignment_id = 51 then d2.total_promotion_amount
                 when p.custom_field_group_assignment_id = 52 then d2.total_cash_down_payment
                 when p.custom_field_group_assignment_id = 53 then d2.total_ancillary_cost_with_fees
            else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SCHEDULE SITE SURVEY*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            5,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 3
     where deal_id is not null
       and 3 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                5,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                site_survey_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             site_survey_scheduled_date is not null and site_survey_completed_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 5
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,timestamp_value,
                                                         int_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 15 then ((d2.site_survey_completed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 16 then ((d2.site_survey_completed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 17 then (select up.user_id
                                                                    from blueraven.deal_calendar_event dce
                                                                    inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                    where dce.work_type_id = 7 and dce.primary_flag is true and dce.deleted is false
                                                                    and up.primary_flag is true and up.position_id in (7,16)
                                                                    and dce.deal_id = d2.id and
                                                                    (d2.site_survey_completed_date >= up.start_date and case when end_date is not null then d2.site_survey_completed_date <= end_date else 1=1 end) limit 1)
                 when p.custom_field_group_assignment_id = 19 then (select id from flow.list_of_value where parent_id = 353
                                                                                                        and name = d2.site_survey_type)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SITE SURVEY*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            60,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         (d.on_hold IS NULL OR d.on_hold = FALSE) and
            d.site_survey_scheduled_date is not null and site_survey_completed_date is not null and site_survey_uploaded_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                60,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                site_survey_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             site_survey_uploaded_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 60
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 20 then ((site_survey_uploaded_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*CREATE FINAL DESIGN*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            7,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 5
     where deal_id is not null
       and 5 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                7,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                final_design_created_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             final_design_created_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 7
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,
                                                         int_value,int_array_value,timestamp_value,numeric_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 30 then ((site_survey_photos_missing_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 31 then ((site_survey_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')else null end,
            case when p.custom_field_group_assignment_id = 35 then (select id from flow.list_of_value where parent_id = 289
                                                                                                        and name = d2.price_change)
                 when p.custom_field_group_assignment_id = 34 then (select id from flow.list_of_value where parent_id = 151
                                                                                                        and name = d2.kwh_change)
                 when   p.custom_field_group_assignment_id = 33 then (select id from blueraven.user where (first_name||' '||last_name) = d2.final_design_completed_by)
                 when p.custom_field_group_assignment_id = 75 then  d2.panel_quantity
                 when p.custom_field_group_assignment_id = 76 then  (select id from flow.list_of_value where parent_id = 238
                                                                                                         and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 77 then  (select id from flow.list_of_value where parent_id = 143
                                                                                                         and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 74 then  d2.panel_watts
                 when p.custom_field_group_assignment_id = 78 then  d2.first_year_production_estimate
                 else null end,
            case when p.custom_field_group_assignment_id = 29 then (select array_agg(id)
                                                                    from flow.list_of_value
                                                                    where parent_id = 337 and
                                                                    name in (
                                                                     select  * from
                                                                     json_array_elements_text((select site_survey_quality_checklist::json from blueraven.deal
                                                                    where site_survey_quality_checklist is not null and
                                                                          id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 32 then ((final_design_created_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 73 then d2.system_size else null end,
            case when p.custom_field_group_assignment_id = 81 then d2.inverter_rating else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*QA FINAL DESIGN*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            61,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 227
     where deal_id is not null
       and 227 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                61,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                final_design_qa_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             final_design_qa_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 61
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,
                                                         int_value,int_array_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 36 then ((final_design_qa_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 39 then (select id from blueraven.user where (first_name||' '||last_name) = d2.final_design_qa_by)
                 else null end,
            case when p.custom_field_group_assignment_id = 37 then (select array_agg(id)
                                                                    from flow.list_of_value
                                                                    where parent_id = 106 and
                                                                            name in (
                                                                            select  * from
                                                                                json_array_elements_text((select site_survey_quality_checklist::json from blueraven.deal
                                                                                                          where site_survey_quality_checklist is not null and
                                                                                                                  id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 38 then final_design_qa_feedback else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );



/*SEND FINAL DESIGN TO CUSTOMER*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            8,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 6
     where deal_id is not null
       and 6 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                8,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                final_design_sent_to_customer_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             final_design_sent_to_customer_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 8
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 59 then ((final_design_sent_to_customer_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );


/*FINAL DESIGN COMPLETION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            9,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 206
     where deal_id is not null
       and 206 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                9,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                greatest(final_design_signed_date,agreement_signed_date)
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             final_design_signed_date is not null and utility_bill_verified_date is not null and agreement_signed_date is not null and
              (financier not IN ('["Cash"]') or first_cash_payment_paid_date is not null)
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 9
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 60 then ((final_design_signed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );


/*CREATE PLAN SET*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            62,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 12
     where deal_id is not null
       and 12 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                62,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                plan_set_created_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             plan_set_created_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 62
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,numeric_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 63 then ((plan_set_created_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 64 then (select id from blueraven.user where (first_name||' '||last_name) = d2.plan_set_qa_by)
                 when p.custom_field_group_assignment_id = 69 then  d2.panel_quantity
                 when p.custom_field_group_assignment_id = 70 then  (select id from flow.list_of_value where parent_id = 238
                                                                                                         and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 79 then  (select id from flow.list_of_value where parent_id = 143
                                                                                                         and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 71 then  d2.panel_watts
                -- when p.custom_field_group_assignment_id = 72 then  d2.1st_year_production_estimate)
                else null end,
            case when p.custom_field_group_assignment_id = 68 then d2.system_size else null end,
            case when p.custom_field_group_assignment_id = 80 then d2.inverter_rating else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*QA PLAN SET*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            63,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 228
     where deal_id is not null
       and 228 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                63,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                plan_set_qa_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             plan_set_qa_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 63
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         int_value,timestamp_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 66 then (select id from blueraven.user where (first_name||' '||last_name) = d2.plan_set_created_by limit 1)
                 else null end,
            case when p.custom_field_group_assignment_id = 65 then ((plan_set_qa_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*CREATE PERMIT PACK*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            10,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         (d.on_hold IS NULL OR d.on_hold = FALSE) and
         site_survey_verified_date IS NOT NULL AND ((plan_set_qa_date is not null and permit_pack_complete is null) OR
                                                    ((permit_pack_revision_requested_date IS NOT NULL
                                                        AND permit_pack_revision_complete_date IS NULL) OR
                                                     (permit_revision_b_requested_date IS NOT NULL AND
                                                      permit_revision_b_complete_date IS NULL) OR (permit_revision_c_requested_date IS NOT NULL AND permit_revision_c_complete_date IS NULL) OR
                                                     (as_built_permit_required_date is not null and as_built_permit_packet_complete_date is null) OR
                                                     (redesign_signed_date is not null AND redesign_signed_date :: DATE >= '2019-06-11' AND
                                                      greatest(permit_pack_complete,permit_pack_revision_complete_date,permit_revision_b_complete_date,permit_revision_c_complete_date):: DATE < redesign_signed_date :: DATE)
                                                        )));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                10,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_complete
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pack_complete is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 10
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 67 then ((permit_pack_complete AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                10,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_revision_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pack_revision_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 10
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 67 then ((permit_pack_revision_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                10,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_b_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_b_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 10
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 67 then ((permit_revision_b_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                10,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_c_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_c_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 10
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 67 then ((permit_revision_c_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*STRUCTURAL ANALYSIS*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            64,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 238
     where deal_id is not null
       and 238 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                64,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                structural_analysis_complete::timestamp
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             structural_analysis_complete is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 64
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 83 then ((structural_analysis_complete::date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 82 then ((structural_analysis_required::date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 84 then (select id from blueraven.user where (first_name||' '||last_name) = d2.structural_analysis_completed_by) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*STRUCTURAL Engineering Stamp*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            12,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id NOT IN (1,2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') and originator_id = 1 AND
            (d.on_hold IS NULL OR d.on_hold = FALSE) and ((engineering_stamp_required != 'No' AND engineering_stamp_required IS NOT NULL AND engineering_stamp_received_date IS NULL)
         OR
                                                          (engineering_restamp_required_date IS NOT NULL AND engineering_restamp_received_date IS NULL)
         ));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                12,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                engineering_stamp_received_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             engineering_stamp_received_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 12
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 86 then ((engineering_stamp_requested_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 87 then ((engineering_stamp_received_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 95 then (select id from flow.list_of_value where parent_id = 468
                                                                                                        and name = d2.engineering_stamp_required) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Electrical Engineering Stamp*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            65,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         (d.on_hold IS NULL OR d.on_hold = FALSE) and (
             (electrical_engineering_stamp_required != 'No' AND electrical_engineering_stamp_required IS NOT NULL AND electrical_engineering_stamp_received_date IS NULL)
             OR
             (electrical_engineering_restamp_requested_date IS NOT NULL AND electrical_engineering_restamp_received_date IS NULL)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                65,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                electrical_engineering_stamp_received_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             electrical_engineering_stamp_received_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 65
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 91 then ((electrical_engineering_stamp_received_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 92 then ((electrical_engineering_stamp_requested_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 96 then (select id from flow.list_of_value where parent_id = 477
                                                                                                        and name = d2.electrical_engineering_stamp_required) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SCHEDULE PERMIT PACK SUBMISSION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            13,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 15
     where deal_id is not null
       and 15 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                13,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_packet_ready_to_submit_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_packet_ready_to_submit_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 13
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,numeric_value,boolean_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 97 then ((permit_packet_submitted_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 98 then ((permit_packet_submitted_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 99 then (select up.user_id
                                                                    from blueraven.deal_calendar_event dce
                                                                             inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                    where dce.work_type_id = 9 and dce.primary_flag is true and dce.deleted is false
                                                                      and up.primary_flag is true and up.position_id in (7,16)
                                                                      and dce.deal_id = d2.id and
                                                                        (d2.permit_packet_submitted_date >= up.start_date and case when end_date is not null then d2.permit_packet_submitted_date <= end_date else 1=1 end) limit 1) else null end,
            case when p.custom_field_group_assignment_id = 100 then permit_fee
                when p.custom_field_group_assignment_id = 101 then permit_deposit_fee::numeric else null end,
            case when p.custom_field_group_assignment_id = 102 then permit_fee_paid else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                13,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_revision_submittal_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pack_revision_submittal_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 13
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,numeric_value,boolean_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 97 then ((permit_pack_revision_submittal_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 98 then ((permit_pack_revision_submittal_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 99 then (select up.user_id
                                                                    from blueraven.deal_calendar_event dce
                                                                             inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                    where dce.work_type_id = 16 and dce.primary_flag is true and dce.deleted is false
                                                                      and up.primary_flag is true and up.position_id in (7,16)
                                                                      and dce.deal_id = d2.id and
                                                                        (d2.permit_pack_revision_submittal_date >= up.start_date and case when end_date is not null then d2.permit_pack_revision_submittal_date <= end_date else 1=1 end) limit 1) else null end,
            case when p.custom_field_group_assignment_id = 100 then permit_fee
                 when p.custom_field_group_assignment_id = 101 then permit_deposit_fee::numeric else null end,
            case when p.custom_field_group_assignment_id = 102 then permit_fee_paid else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                13,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_b_submittal_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_b_submittal_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 13
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,numeric_value,boolean_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 97 then ((permit_revision_b_submittal_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 98 then ((permit_revision_b_submittal_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 99 then (select up.user_id
                                                                    from blueraven.deal_calendar_event dce
                                                                             inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                    where dce.work_type_id = 18 and dce.primary_flag is true and dce.deleted is false
                                                                      and up.primary_flag is true and up.position_id in (7,16)
                                                                      and dce.deal_id = d2.id and
                                                                        (d2.permit_revision_b_submittal_date >= up.start_date and case when end_date is not null then d2.permit_revision_b_submittal_date <= end_date else 1=1 end) limit 1) else null end,
            case when p.custom_field_group_assignment_id = 100 then permit_fee
                 when p.custom_field_group_assignment_id = 101 then permit_deposit_fee::numeric else null end,
            case when p.custom_field_group_assignment_id = 102 then permit_fee_paid else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                13,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_c_submittal_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_c_submittal_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 13
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,numeric_value,boolean_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 97 then ((permit_revision_c_submittal_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 98 then ((permit_revision_c_submittal_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 99 then (select up.user_id
                                                                    from blueraven.deal_calendar_event dce
                                                                             inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                    where dce.work_type_id = 19 and dce.primary_flag is true and dce.deleted is false
                                                                      and up.primary_flag is true and up.position_id in (7,16)
                                                                      and dce.deal_id = d2.id and
                                                                        (d2.permit_revision_c_submittal_date >= up.start_date and case when end_date is not null then d2.permit_revision_c_submittal_date <= end_date else 1=1 end) limit 1) else null end,
            case when p.custom_field_group_assignment_id = 100 then permit_fee
                 when p.custom_field_group_assignment_id = 101 then permit_deposit_fee::numeric else null end,
            case when p.custom_field_group_assignment_id = 102 then permit_fee_paid else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*VERIFY PERMIT PACK SUBMISSION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            67,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 40
     where deal_id is not null
       and 40 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                67,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_submittal_verified
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pack_submittal_verified is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 67
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 104 then ((permit_pack_submittal_verified AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 105 then (select id from flow.list_of_value where parent_id = 263
                                                                                                         and name = d2.permit_location) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                67,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_revision_submittal_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pack_revision_submittal_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 67
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 104 then ((permit_pack_revision_submittal_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 105 then (select id from flow.list_of_value where parent_id = 263
                                                                                                         and name = d2.permit_pack_revision_location) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                67,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_b_submitted_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_b_submitted_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 67
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 104 then ((permit_revision_b_submitted_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 105 then (select id from flow.list_of_value where parent_id = 263
                                                                                                         and name = d2.permit_revision_b_location) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                67,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_c_submitted_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_c_submitted_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 67
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 104 then ((permit_revision_c_submitted_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 105 then (select id from flow.list_of_value where parent_id = 263
                                                                                                       and name = d2.permit_revision_c_location) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*VERIFY PERMIT APPROVAL*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            15,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 209
     where deal_id is not null
       and 209 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                15,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_approved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_approved_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 15
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 106 then ((permit_approved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 107 then (select id from flow.list_of_value where parent_id = 271
                                                                                                        and name = d2.permit_outcome)
                when p.custom_field_group_assignment_id = 108 then (select id from flow.list_of_value where parent_id = 263
                                                                                                and name = d2.permit_location) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                15,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_revision_approved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pack_revision_approved_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 15
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 106 then ((permit_pack_revision_approved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 107 then (select id from flow.list_of_value where parent_id = 271
                                                                                                         and name = d2.permit_pack_revision_outcome)
                 when p.custom_field_group_assignment_id = 108 then (select id from flow.list_of_value where parent_id = 263
                                                                                                         and name = d2.permit_pack_revision_location) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                15,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_b_approved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_b_approved_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 15
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 106 then ((permit_revision_b_approved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 107 then (select id from flow.list_of_value where parent_id = 271
                                                                                                         and name = d2.permit_revision_b_outcome)
                 when p.custom_field_group_assignment_id = 108 then (select id from flow.list_of_value where parent_id = 263
                                                                                                         and name = d2.permit_revision_b_location) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                15,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_c_approved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_c_approved_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 15
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 106 then ((permit_revision_c_approved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 107 then (select id from flow.list_of_value where parent_id = 271
                                                                                                         and name = d2.permit_revision_c_outcome)
                 when p.custom_field_group_assignment_id = 108 then (select id from flow.list_of_value where parent_id = 263
                                                                                                         and name = d2.permit_revision_c_location) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*UTILITY BILL VERIFICATION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            68,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 49
     where deal_id is not null
       and 49 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                68,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                utility_bill_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             utility_bill_verified_date is not null and ((proof_of_howmeowners_insurance_required is false or proof_of_howmeowners_insurance_required is null) or proof_of_homeowners_insurance_obtained_date is not null)
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 68
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 109 then ((utility_bill_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 110 then ((proof_of_homeowners_insurance_obtained_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 111 then (select id from flow.list_of_value where parent_id = 304
                                                                                                        and case when name = 'Yes' then True else false end = d2.proof_of_howmeowners_insurance_required) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*READY TO SEND OR SIGN INTERCONNECTION APPLICATION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            69,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 116
     where deal_id is not null
       and 116 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                69,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                nem_signed_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             nem_signed_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 69
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 112 then ((nem_signed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*READY FOR INTERCONNECTION APPLICATION SUBMISSION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            19,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 8
     where deal_id is not null
       and 8 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                19,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                nem_submitted_to_utility_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             nem_submitted_to_utility_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 19
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 113 then ((nem_submitted_to_utility_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*VERIFY INTERCONNECTION APPLICATION APPROVAL*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            20,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 34
     where deal_id is not null
       and 34 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                20,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                nem_approved_by_utility_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             nem_approved_by_utility_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 20
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 114 then ((nem_approved_by_utility_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 115 then ((interconnection_application_rejected AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*REJECTED INTERCONNECTION APPLICATIONS*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            70,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 239
     where deal_id is not null
       and 239 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                70,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                nem_approved_by_utility_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             nem_approved_by_utility_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 70
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 116 then ((nem_approved_by_utility_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*DETERMINE HOA*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            21,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 35
     where deal_id is not null
       and 35 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                21,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                hoa_request_for_approval_submitted_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             hoa_contact_information is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 21
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 117 then d2.hoa_contact_information else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SUBMIT HOA APPLICATION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            22,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 9
     where deal_id is not null
       and 9 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                22,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                hoa_request_for_approval_submitted_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             hoa_request_for_approval_submitted_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 22
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 118 then ((hoa_request_for_approval_submitted_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );


/*VERIFY HOA APPLICATION APPROVAL*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            23,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 10
     where deal_id is not null
       and 10 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                23,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                hoa_approval_received_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             hoa_approval_received_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 23
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 119 then ((hoa_approval_received_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*CREATE IN-HOUSE MPU PERMIT PACK*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            24,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 214
     where deal_id is not null
       and 214 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                24,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                in_house_mpu_permit_pack_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             in_house_mpu_permit_pack_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 24
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 120 then ((in_house_mpu_permit_pack_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SCHEDULE IN-HOUSE MPU PERMIT SUBMISSION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            25,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 215
     where deal_id is not null
       and 215 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                25,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                in_house_mpu_permit_submittal_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             in_house_mpu_permit_submittal_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 25
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 121 then ((in_house_mpu_permit_submittal_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 122 then ((in_house_mpu_permit_submittal_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );



/*VERIFY IN-HOUSE MPU SUBMISSION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            26,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 216
     where deal_id is not null
       and 216 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                26,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                in_house_mpu_permit_submittal_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             in_house_mpu_permit_submittal_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 26
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 124 then ((in_house_mpu_permit_submittal_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Verify In-house MPU Permit Approval*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            27,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 217
     where deal_id is not null
       and 217 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                27,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                in_house_mpu_permit_approved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             in_house_mpu_permit_approved_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 27
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 125 then ((in_house_mpu_permit_approved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule Permit Pickup and Delivery*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            16,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 71
     where deal_id is not null
       and 71 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                16,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pick_up_scheduled
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pick_up_scheduled is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 16
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 128 then ((permit_pick_up_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 129 then ((permit_pick_up_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 130 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 8 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.permit_pick_up_date >= up.start_date and case when end_date is not null then d2.permit_pick_up_date <= end_date else 1=1 end) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                16,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_revision_pickup_scheduled
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pack_revision_pickup_scheduled is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 16
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 128 then ((permit_pack_revision_pickup_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 129 then ((permit_pack_revision_pickup_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 130 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 17 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.permit_pack_revision_pickup_date >= up.start_date and case when end_date is not null then d2.permit_pack_revision_pickup_date <= end_date else 1=1 end) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                16,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_b_pickup_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_b_pickup_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 16
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 128 then ((permit_revision_b_pickup_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 129 then ((permit_revision_b_pickup_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 130 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 20 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.permit_revision_b_pickup_date >= up.start_date and case when end_date is not null then d2.permit_revision_b_pickup_date <= end_date else 1=1 end) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                16,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_c_pickup_scheduled
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_c_pickup_scheduled is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 16
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 128 then ((permit_revision_c_pickup_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 129 then ((permit_revision_c_pickup_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 130 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 21 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.permit_revision_c_pickup_date >= up.start_date and case when end_date is not null then d2.permit_revision_c_pickup_date <= end_date else 1=1 end) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );


/*Schedule Permit Application Signature*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            66,
            (SELECT id FROM flow.company_process_step_status_type
            WHERE case when d.cancelled_date is null then
                             process_step_status_type = 'Active' else
                             process_step_status_type = 'Cancelled' end
            and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 29
     where deal_id is not null
       and 29 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                66,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                fl_noc_application_signature_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             fl_noc_application_signature_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 66
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 131 then ((fl_noc_application_signature_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 132 then ((fl_noc_application_signature_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')else null end,
            case when p.custom_field_group_assignment_id = 133 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 30 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.fl_noc_application_signature_date >= up.start_date and case when end_date is not null then d2.fl_noc_application_signature_date <= end_date else 1=1 end) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*verify Permit Application Signature*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            71,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 48
     where deal_id is not null
       and 48 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                71,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                fl_noc_application_signature_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             fl_noc_application_signature_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 71
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 134 then ((fl_noc_application_signature_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Permit Approved, Not Ready to Schedule Installation*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            32,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 207
     where deal_id is not null
       and 207 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                32,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                installation_ready_to_schedule_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             installation_ready_to_schedule_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 32
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 126 then ((installation_ready_to_schedule_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule Installation*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            33,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 19
     where deal_id is not null
       and 19 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                33,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                scheduled_installation_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ((scheduled_installation_date is not null and installation_date :: DATE < (now() AT TIME ZONE 'US/Mountain') :: DATE AND
               scheduled_installation_date :: DATE >
               greatest(redesign_ready_to_send_date,regen_ready_to_send_date,permit_pack_complete,permit_pack_revision_complete_date,
                        permit_revision_b_complete_date,permit_revision_c_complete_date,bom_created_date) :: DATE))
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 33
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 135 then ((installation_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 136 then ((installation_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')else null end,
            case when p.custom_field_group_assignment_id = 137 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 1 and dce.primary_flag is true and dce.deleted is false) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SUBSTANTIAL COMPLETION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            35,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 20
     where deal_id is not null
       and 20 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                35,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                substantial_completion_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             substantial_completion_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 35
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 138 then ((substantial_completion_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule Installation Closeout Work*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            72,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 28
     where deal_id is not null
       and 28 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                72,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                installation_closeout_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             installation_closeout_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 72
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 139 then ((installation_closeout_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 140 then ((installation_closeout_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 141 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 2 and dce.primary_flag is true and dce.deleted is false) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Order Materials*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            37,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 47
     where deal_id is not null
       and 47 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                37,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                materials_ordered_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             materials_ordered_date IS NOT NULL AND materials_ordered_date >= scheduled_installation_date
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 37
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 142 then ((materials_ordered_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Create Placard*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            38,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 122
     where deal_id is not null
       and 122 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                38,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                placard_ordered_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             placard_ordered_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 38
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 143 then ((placard_ordered_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                38,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                additional_placard_ordered_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             additional_placard_ordered_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 38
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 143 then ((additional_placard_ordered_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Verify Placard Delivery*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            39,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 121
     where deal_id is not null
       and 121 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                39,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                placard_shipped_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             placard_shipped_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 39
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 144 then ((placard_shipped_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 145 then placard_tracking_number else null end,
                     now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                39,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                additional_placard_shipped_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             additional_placard_shipped_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 39
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 144 then ((additional_placard_shipped_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 145 then placard_tracking_number else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Substantial Completion Approval*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            73,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 21
     where deal_id is not null
       and 21 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                73,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                substantial_completion_approved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             substantial_completion_approved_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 73
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 147 then ((substantial_completion_approved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SCHEDULE AHJ INSPECTION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            40,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 22
     where deal_id is not null
       and 22 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                40,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                ahj_inspection_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ahj_inspection_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 40
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 148 then ((ahj_inspection_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 149 then ((ahj_inspection_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 150 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 3 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.ahj_inspection_date >= up.start_date and case when end_date is not null then d2.ahj_inspection_date <= end_date else 1=1 end) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                40,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                ahj_reinspection_scheduled
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ahj_reinspection_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 40
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 148 then ((ahj_reinspection_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 149 then ((ahj_reinspection_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 150 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 5 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.ahj_inspection_date >= up.start_date and case when end_date is not null then d2.ahj_inspection_date <= end_date else 1=1 end) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                40,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                ahj_reinspection_b_scheduled
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ahj_reinspection_b_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 40
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 148 then ((ahj_reinspection_b_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 149 then ((ahj_reinspection_b_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 150 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 23 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.ahj_inspection_date >= up.start_date and case when end_date is not null then d2.ahj_inspection_date <= end_date else 1=1 end) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Not ready to schedule inspection*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            74,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 63
     where deal_id is not null
       and 63 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                74,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                ahj_inspection_ready_to_schedule_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ahj_inspection_ready_to_schedule_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 74
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 148 then ((ahj_inspection_ready_to_schedule_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
             now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Needs AHJ Inspection Verification*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            46,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 23
     where deal_id is not null
       and 23 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                46,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                ahj_inspection_passed_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ahj_inspection_passed_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 46
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 152 then ((ahj_inspection_passed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 153 then (select id from flow.list_of_value where parent_id = 45
                                                                                                        and name = d2.ahj_inspection_outcome) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                46,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                ahj_inspection_passed_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ahj_reinspection_date is not null
           and originator_id = 1)
        returning *),
           p as (
               select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
               from flow.custom_field_group_assignment cfga
                        inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                        inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                        inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                        inner join flow.data_type dt on dt.id = cdt.data_type_id
               where cfg.process_step_id = 46
                 and cf.archived is false and cfg.archived is false and cfga.archived is false
           )
      insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                               date_value,int_value,
                                                               date_created, date_modified, created_by_id, modified_by_id)
          (select p1.id,p.custom_field_group_assignment_id,
                  case when p.custom_field_group_assignment_id = 152 then ((ahj_reinspection_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
                  case when p.custom_field_group_assignment_id = 153 then (select id from flow.list_of_value where parent_id = 45
                                                                                                               and name = d2.ahj_reinspection_outcome) else null end,
                  now(),now(),2350555,2350555
           from blueraven.deal d2
                    inner join process_step1 p1 on p1.project_id = d2.id
                    cross join p
          );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                46,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                ahj_inspection_passed_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ahj_reinspection_b_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 46
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 152 then ((ahj_reinspection_b_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 153 then (select id from flow.list_of_value where parent_id = 45
                                                                                                         and name = d2.ahj_reinspection_b_outcome) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Submit AHJ Inspection Approval to Utility*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            47,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 72
     where deal_id is not null
       and 72 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                47,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                greatest(verified_inspection_approval_received_by_utility_date,ahj_inspection_approval_submitted_date)
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             verified_inspection_approval_received_by_utility_date is not null or ahj_inspection_approval_submitted_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 47
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 154 then ((greatest(verified_inspection_approval_received_by_utility_date,ahj_inspection_approval_submitted_date) AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Order Utility Meter*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            48,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 208
     where deal_id is not null
       and 208 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                48,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                utility_meter_ordered_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             utility_meter_ordered_date is not null
             and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 48
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 155 then ((utility_meter_ordered_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Obtain PTO*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            50,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 50
     where deal_id is not null
       and 50 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                50,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                greatest(permission_to_operate_date,utility_meter_set_date)
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permission_to_operate_date is not null and utility_meter_set_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 50
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 157 then ((utility_meter_set_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 158 then ((permission_to_operate_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*schedule work order*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            54,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 26
     where deal_id is not null
       and 26 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                54,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                system_service_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             system_service_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 54
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 159 then ((system_service_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 160 then ((system_service_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 161 then (select up.user_id
                                                                    from blueraven.deal_calendar_event dce
                                                                             inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                    where dce.work_type_id = 6 and dce.primary_flag is true and dce.deleted is false
                                                                      and up.primary_flag is true and up.position_id in (7,16)
                                                                      and dce.deal_id = d2.id and
                                                                        (d2.system_service_date >= up.start_date and case when end_date is not null then d2.system_service_date <= end_date else 1=1 end ) limit 1) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Verify Work Order*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            55,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 27
     where deal_id is not null
       and 27 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                55,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                work_order_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             work_order_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 55
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 162 then ((work_order_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule Utility Re-inspection*/
-- INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
--     (SELECT project.id,
--             42,
--             (SELECT id FROM flow.company_process_step_status_type
--              WHERE case when d.cancelled_date is null then
--                                 process_step_status_type = 'Active' else
--                                 process_step_status_type = 'Cancelled' end
--                and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
--             2350555 as created_by_id,
--now()
--      from flow.project p
--               inner join blueraven.deal d on d.id = p.id
--               inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
--               inner join blueraven.card c on c.id = 213
--      where deal_id is not null
--        and 213 = any(work_queue_deal_ids) and
--          ((exclude_card_ids IS NULL)
--              OR (exclude_card_ids IS NOT NULL AND
--                  NOT work_queue_deal_ids && c.exclude_card_ids)));
--
-- with process_step1 as (
--     INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
--         (SELECT project.id,
--                 42,
--                 (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
--                                                                         and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
--                 2350555 as created_by_id,
--                 utility_reinspection_requested_date
--          FROM flow.project
--                   INNER JOIN blueraven.deal d
--                              ON project.id = d.id
--          where
--              utility_reinspection_requested_date is not null
--            and originator_id = 1)
--         returning *),
--      p as (
--          select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
--          from flow.custom_field_group_assignment cfga
--                   inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
--                   inner join flow.custom_field cf on cf.id = cfga.custom_field_id
--                   inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
--                   inner join flow.data_type dt on dt.id = cdt.data_type_id
--          where cfg.process_step_id = 42
--            and cf.archived is false and cfg.archived is false and cfga.archived is false
--      )
-- insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
--                                                          date_value,
--                                                          date_created, date_modified, created_by_id, modified_by_id)
--     (select p1.id,p.custom_field_group_assignment_id,
--             case when p.custom_field_group_assignment_id = 163 then ((utility_reinspection_requested_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
--                  else null end,
--             now(),now(),2350555,2350555
--      from blueraven.deal d2
--               inner join process_step1 p1 on p1.project_id = d2.id
--               cross join p
--     );

/*Structural Engineering Review*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            75,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 226
     where deal_id is not null
       and 226 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                75,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                structural_engineering_review_complete_date::timestamp
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             structural_engineering_review_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 75
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_array_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 165 then ((structural_engineering_review_required_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 167 then ((structural_engineering_review_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 166 then (select array_agg(id)
                                                                    from flow.list_of_value
                                                                    where parent_id = 367 and
                                                                            name in (
                                                                            select  * from
                                                                                json_array_elements_text((select structural_engineering_review_type::json from blueraven.deal
                                                                                                          where structural_engineering_review_type is not null and
                                                                                                                  id = d2.id)))) else null end,
         case when p.custom_field_group_assignment_id = 164 then (select id from blueraven.user where (first_name||' '||last_name) = d2.structural_engineering_review_by) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                75,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                structural_engineering_review_b_complete_date::timestamp
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             structural_engineering_review_b_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 75
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_array_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 165 then ((structural_engineering_review_b_required_date::timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 167 then ((structural_engineering_review_b_complete_date::timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 166 then (select array_agg(id)
                                                                     from flow.list_of_value
                                                                     where parent_id = 367 and
                                                                             name in (
                                                                             select  * from
                                                                                 json_array_elements_text((select structural_engineering_review_b_type::json from blueraven.deal
                                                                                                           where structural_engineering_review_b_type is not null and
                                                                                                                   id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 164 then (select id from blueraven.user where (first_name||' '||last_name) = d2.structural_engineering_review_b_by) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );
with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                75,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                structural_engineering_review_c_complete_date::timestamp
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             structural_engineering_review_c_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 75
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_array_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 165 then ((structural_engineering_review_c_required_date::timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 167 then ((structural_engineering_review_c_complete_date::timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 166 then (select array_agg(id)
                                                                     from flow.list_of_value
                                                                     where parent_id = 367 and
                                                                             name in (
                                                                             select  * from
                                                                                 json_array_elements_text((select structural_engineering_review_c_type::json from blueraven.deal
                                                                                                           where structural_engineering_review_c_type is not null and
                                                                                                                   id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 164 then (select id from blueraven.user where (first_name||' '||last_name) = d2.structural_engineering_review_c_by) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Electrical Engineering Review*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            76,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 212
     where deal_id is not null
       and 212 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                76,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                engineering_review_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             engineering_review_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 76
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_array_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 168 then ((engineering_review_required_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 170 then ((engineering_review_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 169 then (select array_agg(id)
                                                                     from flow.list_of_value
                                                                     where parent_id = 367 and
                                                                             name in (
                                                                             select  * from
                                                                                 json_array_elements_text((select engineering_review_type::json from blueraven.deal
                                                                                                           where engineering_review_type is not null and
                                                                                                                   id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 171 then (select id from blueraven.user where (first_name||' '||last_name) = d2.electrical_engineering_review_by) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                76,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                electrical_engineering_review_b_complete_date::timestamp
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             electrical_engineering_review_b_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 76
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_array_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 168 then ((electrical_engineering_review_b_required_date::timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 170 then ((electrical_engineering_review_b_complete_date::timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 169 then (select array_agg(id)
                                                                     from flow.list_of_value
                                                                     where parent_id = 367 and
                                                                             name in (
                                                                             select  * from
                                                                                 json_array_elements_text((select electrical_engineering_review_b_type::json from blueraven.deal
                                                                                                           where electrical_engineering_review_b_type is not null and
                                                                                                                   id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 171 then (select id from blueraven.user where (first_name||' '||last_name) = d2.electrical_engineering_review_b_by) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );
with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                76,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                electrical_engineering_review_c_complete_date::timestamp
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             electrical_engineering_review_c_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 76
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_array_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 168 then ((electrical_engineering_review_c_required_date::timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 170 then ((electrical_engineering_review_c_complete_date::timestamp AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 169 then (select array_agg(id)
                                                                     from flow.list_of_value
                                                                     where parent_id = 367 and
                                                                             name in (
                                                                             select  * from
                                                                                 json_array_elements_text((select electrical_engineering_review_c_type::json from blueraven.deal
                                                                                                           where electrical_engineering_review_c_type is not null and
                                                                                                                   id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 171 then (select id from blueraven.user where (first_name||' '||last_name) = d2.electrical_engineering_review_c_by) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Low production inquiry review*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            80,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 186
     where deal_id is not null
       and 186 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                80,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                low_production_inquiry_reviewed_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             low_production_inquiry_reviewed_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 80
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 176 then ((d2.low_production_inquiry_requested_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 177 then ((d2.low_production_inquiry_reviewed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 178 then (select id from flow.list_of_value where parent_id = 154
                                                                                                         and name = d2.low_production_inquiry_resolution)
                 else null end,
        case when p.custom_field_group_assignment_id = 179  then d2.low_production_inquiry_details else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Low production inquiry resolution*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            79,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 185
     where deal_id is not null
       and 185 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                79,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                low_production_inquiry_resolved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             low_production_inquiry_resolved_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 79
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 175 then ((d2.low_production_inquiry_resolved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Create Structural Post-Install Engineering Letter*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            77,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND originator_id = 1 AND
            (d.on_hold IS NULL OR d.on_hold = FALSE) AND substantial_completion_date is not null AND
            (
                (structural_post_install_letter_required_date is not null AND structural_post_install_engineering_letter_complete_date IS NULL)
                )));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                77,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                structural_post_install_engineering_letter_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             structural_post_install_engineering_letter_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 77
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 173 then ((d2.structural_post_install_engineering_letter_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Create Electrical Post-Install Engineering Letter*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            78,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND originator_id = 1 AND
            (d.on_hold IS NULL OR d.on_hold = FALSE) AND substantial_completion_date is not null AND
            (electrical_post_install_letter_required_date is not null AND electrical_post_install_letter_complete_date IS NULL)
               ));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                78,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                electrical_post_install_letter_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             electrical_post_install_letter_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 78
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 174 then ((d2.electrical_post_install_letter_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*In-house MPU Prep Work*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            81,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 225
     where deal_id is not null
       and 225 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                81,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                greatest(in_house_mpu_inspection_scheduled_date, in_house_mpu_materials_ordered_date)
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             in_house_mpu_inspection_scheduled_date IS NOT NULL AND in_house_mpu_materials_ordered_date IS NOT NULL
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 81
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 180 then ((d2.in_house_mpu_materials_ordered_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 181 then ((d2.in_house_mpu_inspection_scheduled_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Send/Sign Utility Rebate Application*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            82,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 222
     where deal_id is not null
       and 222 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                82,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                greatest(utility_rebate_application_sent_to_homeowner_date, utility_rebate_application_signed_date)
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             utility_rebate_application_sent_to_homeowner_date is not null and utility_rebate_application_signed_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 82
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 182 then ((d2.utility_rebate_application_sent_to_homeowner_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 183 then ((d2.utility_rebate_application_signed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Utility Rebate Application Approval*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            83,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 223
     where deal_id is not null
       and 223 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                83,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                utility_rebate_application_approved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             utility_rebate_application_approved_date is not null and reserved_utility_rebate_amount is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 83
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,numeric_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 184 then ((d2.utility_rebate_application_approved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 185 then ((d2.utility_rebate_application_submitted_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when  p.custom_field_group_assignment_id = 186 then d2.reserved_utility_rebate_amount
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*verify permit/pickup delivery*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            17,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 46
     where deal_id is not null
       and 46 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                17,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pickup_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_pickup_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 17
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 187 then ((d2.permit_pickup_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when  p.custom_field_group_assignment_id = 188 then (select id from flow.list_of_value where parent_id = 263
                                                                                                          and name = d2.permit_location)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                17,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_pickup_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_pickup_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 17
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 187 then ((d2.permit_revision_pickup_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when  p.custom_field_group_assignment_id = 188 then (select id from flow.list_of_value where parent_id = 263
                                                                                                          and name = d2.permit_location)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                17,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_b_pickup_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_b_pickup_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 17
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 187 then ((d2.permit_revision_b_pickup_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when  p.custom_field_group_assignment_id = 188 then (select id from flow.list_of_value where parent_id = 263
                                                                                                          and name = d2.permit_location)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                17,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_c_pickup_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             permit_revision_c_pickup_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 17
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 187 then ((d2.permit_revision_c_pickup_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when  p.custom_field_group_assignment_id = 188 then (select id from flow.list_of_value where parent_id = 263
                                                                                                          and name = d2.permit_location)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule in-house MPU*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            28,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 219
     where deal_id is not null
       and 219 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                28,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                in_house_mpu_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             in_house_mpu_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 28
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 189 then ((d2.in_house_mpu_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 190 then ((d2.in_house_mpu_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when  p.custom_field_group_assignment_id = 191 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 27 and dce.primary_flag is true and dce.deleted is false)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Verify In-house MPU Completion*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            29,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 220
     where deal_id is not null
       and 220 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                29,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                in_house_mpu_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             in_house_mpu_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 29
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 192 then ((d2.in_house_mpu_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule Non-standard Installation Work*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            30,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 60
     where deal_id is not null
       and 60 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                30,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                non_standard_installation_work_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             non_standard_installation_work_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 30
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 193 then ((d2.non_standard_installation_work_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 194 then ((d2.non_standard_installation_work_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 195 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 13 and dce.primary_flag is true and dce.deleted is false)
                else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Verified Non-standard Installation Work*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            31,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 68
     where deal_id is not null
       and 68 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                31,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                non_standard_installation_work_verified_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             non_standard_installation_work_verified_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 31
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 196 then ((d2.non_standard_installation_work_verified_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule Utility Re-inspection*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            84,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 213
     where deal_id is not null
       and 213 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids))
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                84,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                utility_reinspection_requested_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             utility_reinspection_requested_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 84
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 197 then ((d2.utility_reinspection_requested_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 198 then ((d2.failed_utility_inspection_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule AHJ Inspection Work*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            44,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 61
     where deal_id is not null
       and 61 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                44,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                ahj_inspection_work_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             ahj_inspection_work_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 44
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 199 then ((d2.ahj_inspection_work_scheduled_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 200 then ((d2.ahj_inspection_work_scheduled_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
         case when p.custom_field_group_assignment_id = 201 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 4 and dce.primary_flag is true and dce.deleted is false) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Energize System*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            51,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 69
     where deal_id is not null
       and 69 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                51,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                energized_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             energized_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 51
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 202 then ((d2.energized_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Schedule Energization*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            85,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (2, 3) AND originator_id = 1 AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND
            (d.on_hold IS NULL OR d.on_hold = FALSE) AND
            energization_visit_requested_date IS NOT NULL AND energization_visit_scheduled_date IS NULL));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                85,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                energization_visit_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             energization_visit_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 85
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 203 then ((d2.energization_visit_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                   when  p.custom_field_group_assignment_id = 204 then ((d2.energization_visit_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 205 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 12 and dce.primary_flag is true and dce.deleted is false) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Submit Final Completion*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            52,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and permission_to_operate_date is not null and
            final_completion_submitted_date is null and
            ahj_inspection_passed_date is not null and substantial_completion_approved_date is not null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                52,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                final_completion_submitted_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             final_completion_submitted_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 52
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 206 then ((d2.final_completion_submitted_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Verify Final Completion Approval*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            53,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and
            (final_completion_submitted_date is not null and final_completion_approved_date is null)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                53,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                final_completion_approved_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             final_completion_approved_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 53
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 207 then ((d2.final_completion_approved_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Send first cash invoice to customer*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            56,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 187
     where deal_id is not null
       and 187 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                56,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                first_cash_payment_invoiced_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             first_cash_payment_invoiced_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 56
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,numeric_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 208 then ((d2.first_cash_payment_invoiced_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 209 then d2.first_cash_payment_amount
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Verify First Cash Invoice Paid*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            57,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 190
     where deal_id is not null
       and 190 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                57,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                first_cash_payment_paid_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             first_cash_payment_paid_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 57
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 210 then ((d2.first_cash_payment_paid_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Send Second Cash Invoice to Customer*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            86,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 188
     where deal_id is not null
       and 188 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                86,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                second_cash_payment_invoiced_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             second_cash_payment_invoiced_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 86
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,numeric_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 211 then ((d2.second_cash_payment_invoiced_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            case when p.custom_field_group_assignment_id = 212 then d2.second_cash_payment_amount
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Verify Second Cash Invoice Paid*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            87,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 189
     where deal_id is not null
       and 189 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                87,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                second_cash_payment_paid_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             second_cash_payment_paid_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 87
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 213 then ((d2.second_cash_payment_paid_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );



/*send redesign to customer*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            88,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 65
     where deal_id is not null
       and 65 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                88,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                redesign_sent_to_homeowner_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             redesign_sent_to_homeowner_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 88
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 412 then ((d2.redesign_sent_to_homeowner_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );



/*needs a redesign*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            89,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 13
     where deal_id is not null
       and 13 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                89,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                redesign_ready_to_send_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             redesign_ready_to_send_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 89
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,numeric_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 413 then ((final_design_created_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 422 then (select id from flow.list_of_value where parent_id = 289
                                                                                                        and name = d2.price_change)
                 when p.custom_field_group_assignment_id = 421 then (select id from flow.list_of_value where parent_id = 151
                                                                                                        and name = d2.kwh_change)
                 when   p.custom_field_group_assignment_id = 414 then (select id from blueraven.user where (first_name||' '||last_name) = d2.final_design_completed_by)
                 when p.custom_field_group_assignment_id = 419 then  d2.panel_quantity
                 when p.custom_field_group_assignment_id = 418 then  (select id from flow.list_of_value where parent_id = 238
                                                                                                         and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 423 then  (select id from flow.list_of_value where parent_id = 143
                                                                                                         and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 420 then  d2.panel_watts
                 when p.custom_field_group_assignment_id = 417 then  d2.first_year_production_estimate
                 when p.custom_field_group_assignment_id = 415 then  (select id from flow.list_of_value where parent_id = 331
                                                                                                          and name = d2.secondary_financier)
                 else null end,
         case when p.custom_field_group_assignment_id = 416 then d2.system_size else null end,
            case when p.custom_field_group_assignment_id = 424 then d2.inverter_rating else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*create revise plan set*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            90,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 43
     where deal_id is not null
       and 43 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                90,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_revision_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             (permit_pack_revision_complete_date IS NOT NULL)
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 90
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,numeric_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 413 then ((final_design_created_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 422 then (select id from flow.list_of_value where parent_id = 289
                                                                                                         and name = d2.price_change)
                 when p.custom_field_group_assignment_id = 421 then (select id from flow.list_of_value where parent_id = 151
                                                                                                         and name = d2.kwh_change)
                 when   p.custom_field_group_assignment_id = 414 then (select id from blueraven.user where (first_name||' '||last_name) = d2.final_design_completed_by)
                 when p.custom_field_group_assignment_id = 419 then  d2.panel_quantity
                 when p.custom_field_group_assignment_id = 418 then  (select id from flow.list_of_value where parent_id = 238
                                                                                                          and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 423 then  (select id from flow.list_of_value where parent_id = 143
                                                                                                          and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 420 then  d2.panel_watts
                 when p.custom_field_group_assignment_id = 417 then  d2.first_year_production_estimate
                 when p.custom_field_group_assignment_id = 415 then  (select id from flow.list_of_value where parent_id = 331
                                                                                                          and name = d2.secondary_financier)
                 else null end,
            case when p.custom_field_group_assignment_id = 416 then d2.system_size else null end,
            case when p.custom_field_group_assignment_id = 424 then d2.inverter_rating else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                90,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_b_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             (permit_revision_b_complete_date IS NOT NULL)
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 90
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,numeric_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 413 then ((final_design_created_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 422 then (select id from flow.list_of_value where parent_id = 289
                                                                                                         and name = d2.price_change)
                 when p.custom_field_group_assignment_id = 421 then (select id from flow.list_of_value where parent_id = 151
                                                                                                         and name = d2.kwh_change)
                 when   p.custom_field_group_assignment_id = 414 then (select id from blueraven.user where (first_name||' '||last_name) = d2.final_design_completed_by)
                 when p.custom_field_group_assignment_id = 419 then  d2.panel_quantity
                 when p.custom_field_group_assignment_id = 418 then  (select id from flow.list_of_value where parent_id = 238
                                                                                                          and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 423 then  (select id from flow.list_of_value where parent_id = 143
                                                                                                          and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 420 then  d2.panel_watts
                 when p.custom_field_group_assignment_id = 417 then  d2.first_year_production_estimate
                 when p.custom_field_group_assignment_id = 415 then  (select id from flow.list_of_value where parent_id = 331
                                                                                                          and name = d2.secondary_financier)
                 else null end,
            case when p.custom_field_group_assignment_id = 416 then d2.system_size else null end,
            case when p.custom_field_group_assignment_id = 424 then d2.inverter_rating else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                90,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_c_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             (permit_revision_c_complete_date IS NOT NULL)
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 90
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,numeric_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 413 then ((final_design_created_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 422 then (select id from flow.list_of_value where parent_id = 289
                                                                                                         and name = d2.price_change)
                 when p.custom_field_group_assignment_id = 421 then (select id from flow.list_of_value where parent_id = 151
                                                                                                         and name = d2.kwh_change)
                 when   p.custom_field_group_assignment_id = 414 then (select id from blueraven.user where (first_name||' '||last_name) = d2.final_design_completed_by)
                 when p.custom_field_group_assignment_id = 419 then  d2.panel_quantity
                 when p.custom_field_group_assignment_id = 418 then  (select id from flow.list_of_value where parent_id = 238
                                                                                                          and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 423 then  (select id from flow.list_of_value where parent_id = 143
                                                                                                          and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 420 then  d2.panel_watts
                 when p.custom_field_group_assignment_id = 417 then  d2.first_year_production_estimate
                 when p.custom_field_group_assignment_id = 415 then  (select id from flow.list_of_value where parent_id = 331
                                                                                                          and name = d2.secondary_financier)
                 else null end,
            case when p.custom_field_group_assignment_id = 416 then d2.system_size else null end,
            case when p.custom_field_group_assignment_id = 424 then d2.inverter_rating else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );


/*sign utility rebate application*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            92,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 222
     where deal_id is not null
       and 222 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                92,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                utility_rebate_application_signed_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             utility_rebate_application_signed_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 92
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 435 then ((utility_rebate_application_sent_to_homeowner_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 436 then ((utility_rebate_application_signed_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );


/*create predesign*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            93,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (((d.pre_design_status = 'Submitted' or d.pre_design_status = 'Awaiting Info' or d.pre_design_status = 'In Progress') and
             d.appointment_date is not null) or (d.pre_design_status = 'Complete' and d.pre_design_complete_date is null)) AND
             d.current_stage_id not in (2,3) and (d.appointment_outcome is null or (d.appointment_outcome != 'Cancelled' and d.appointment_outcome != 'No Go' and d.appointment_outcome != 'Low TSRF')));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                93,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                pre_design_complete_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             pre_design_complete_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 93
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 438 then ((pre_design_complete_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')else null end,
            case when p.custom_field_group_assignment_id = 437 then (select id from flow.list_of_value where parent_id = 283
                                                                                                         and name = d2.pre_design_status)else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );



/*Pending Permit Pack Submission*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            94,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         (d.on_hold is null or d.on_hold = false) and

         (permit_packet_submitted_date >= (now() AT TIME ZONE 'US/Mountain') and permit_pack_submittal_verified IS NULL OR

          permit_pack_revision_submittal_date >= (now() AT TIME ZONE 'US/Mountain') and permit_pack_revision_submittal_verified_date
              IS NULL OR

          permit_revision_b_submittal_date >= (now() AT TIME ZONE 'US/Mountain') and permit_revision_b_submitted_verified_date
              IS NULL OR

          permit_revision_c_submittal_date >= (now() AT TIME ZONE 'US/Mountain') and permit_revision_c_submitted_verified_date
              IS NULL));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                94,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_packet_submitted_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
                 permit_packet_submitted_date < (now() AT TIME ZONE 'US/Mountain')
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 94
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,

                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                94,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_pack_revision_submittal_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
                 permit_pack_revision_submittal_date < (now() AT TIME ZONE 'US/Mountain')
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 94
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,

                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                94,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_b_submittal_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
                 permit_revision_b_submittal_date < (now() AT TIME ZONE 'US/Mountain')
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 94
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,

                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                94,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                permit_revision_c_submittal_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
                 permit_revision_c_submittal_date < (now() AT TIME ZONE 'US/Mountain')
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 94
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,

                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Pending Installation Closeout Work*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            95,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where installation_closeout_date >= (now() AT TIME ZONE 'US/Mountain') AND
         substantial_completion_date IS NULL);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                95,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                installation_closeout_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
                 installation_closeout_date < (now() AT TIME ZONE 'US/Mountain')
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 95
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,

                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,

            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*Pending energization*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT project.id,
            96,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where energization_visit_date >= (now() AT TIME ZONE 'US/Mountain') AND
         energized_date IS NULL);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                96,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                energization_visit_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
                 energization_visit_date < (now() AT TIME ZONE 'US/Mountain')
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 96
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*verify energization*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            97,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 69
     where deal_id is not null
       and 69 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                97,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                energized_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             energized_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 97
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 478 then ((energized_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*schedule resurvey*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created)
    (SELECT p.id,
            98,
            (SELECT id FROM flow.company_process_step_status_type
             WHERE case when d.cancelled_date is null then
                                process_step_status_type = 'Active' else
                                process_step_status_type = 'Cancelled' end
               and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id,
now()
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
              inner join blueraven.deal_work_queue dwq on dwq.deal_id  = d.id
              inner join blueraven.card c on c.id = 30
     where deal_id is not null
       and 30 = any(work_queue_deal_ids) and
         ((exclude_card_ids IS NULL)
             OR (exclude_card_ids IS NOT NULL AND
                 NOT work_queue_deal_ids && c.exclude_card_ids)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                98,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                resurvey_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             resurvey_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 98
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 479 then ((resurvey_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 480 then ((resurvey_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 481 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 11 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.resurvey_date >= up.start_date and case when end_date is not null then d2.resurvey_date <= end_date else 1=1 end) limit 1)
                else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                98,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                resurvey_b_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             resurvey_b_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 98
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 479 then ((resurvey_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 480 then ((resurvey_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 481 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 28 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.resurvey_b_date >= up.start_date and case when end_date is not null then d2.resurvey_b_date <= end_date else 1=1 end) limit 1)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date)
        (SELECT project.id,
                98,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id,
now(),
                resurvey_c_scheduled_date
         FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             resurvey_c_scheduled_date is not null
           and originator_id = 1)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 98
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 479 then ((resurvey_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')
                 when p.custom_field_group_assignment_id = 480 then ((resurvey_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            case when p.custom_field_group_assignment_id = 481 then (select up.user_id
                                                                     from blueraven.deal_calendar_event dce
                                                                              inner join blueraven.user_position up on up.org_id = dce.org_id
                                                                     where dce.work_type_id = 29 and dce.primary_flag is true and dce.deleted is false
                                                                       and up.primary_flag is true and up.position_id in (7,16)
                                                                       and dce.deal_id = d2.id and
                                                                         (d2.resurvey_c_date >= up.start_date and case when end_date is not null then d2.resurvey_c_date <= end_date else 1=1 end) limit 1)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );



with update_main as(
    select project_id,process_step_id
    from flow.project_process_step
    group by project_id, process_step_id
    having count(1) <2)
update flow.project_process_step pps
set main = true
from update_main um
where pps.project_id = um.project_id and
        pps.process_step_id = um.process_step_id;


with update_main as(
    select project_id,process_step_id
    from flow.project_process_step
    group by project_id, process_step_id
    having count(1) >1),
     max_day as (
         select max(date_created)as date_created,pp2.project_id,pp2.process_step_id
         from flow.project_process_step pp2
                  inner join update_main um2 on um2.project_id = pp2.project_id and um2.process_step_id = pp2.process_step_id
         group by pp2.project_id,pp2.process_step_id
     ),
     id_to_update as(
         select id
         from flow.project_process_step pp3
                  inner join max_day md on md.date_created = pp3.date_created and md.project_id = pp3.project_id and md.process_step_id = pp3.process_step_id
     )
update flow.project_process_step pps
set main = true
from id_to_update um
where um.id = pps.id;



with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 1)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 2)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 3)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 4)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 5)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 60)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 7)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 61)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 8)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 9)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;



with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 62)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 63)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 10)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 64)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 12)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 65)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 13)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 67)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 15)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 68)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 69)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 19)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 20)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 70)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 21)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 22)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 23)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 24)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 25)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 26)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 27)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 16)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 66)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 71)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 32)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 33)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 35)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id =72 )
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 37)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 38)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 39)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 73)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 40)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 74)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 46)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 47)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 48)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 50)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 54)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 55)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 75)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 76)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 80)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 79)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 77)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 78)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 81)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 82)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 83)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 17)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 28)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 29)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 30)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 31)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 84)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 44)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 51)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 85)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 52)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 53)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 56)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 57)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 86)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 87)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 88)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 89)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 90)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 92)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 93)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 94)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;


with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 95)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 96)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 97)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;

with ids as(
    select ppscfv.id
    from flow.project_process_step_custom_field_value ppscfv
             inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id and pps.main is true and pps.process_step_id = 98)
update flow.project_process_step_custom_field_value p
set id = i.id
from ids i
where i.id = p.id;


