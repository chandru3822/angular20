/*SCHEDULE CLOSER APPOINTMENT*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            1,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where appointment_date is null and d.current_stage_id not in (1,2,3) AND originator_id = 1 and
           (d.financier is null or d.financier != '["One Roof Energy"]' ));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                1,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            2,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where appointment_date is not null
       and appointment_outcome is null
       and d.current_stage_id not in (1,2,3) AND originator_id = 1 and
         (d.financier is null or d.financier != '["One Roof Energy"]'));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                2,
                (SELECT id FROM flow.company_process_step_status_type WHERE case when d.appointment_outcome not in ('Cancelled','Missed') then
                                                                                         process_step_status_type = 'Complete' else
                                                                                         process_step_status_type = 'Cancelled' end
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            3,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where d.proposal_appointment_date is not null
       and d.current_stage_id not in (2, 3)
       and ((d.proposal_status is not null and d.proposal_status != 'Complete') or
            (d.proposal_complete_date is null and d.proposal_status = 'Complete'))
       and (d.appointment_outcome is null or
            (d.appointment_outcome != 'Cancelled' and d.appointment_outcome != 'No Go'))
       and d.current_stage_id not in (1,2,3) AND originator_id = 1 and
         (d.financier is null or d.financier != '["One Roof Energy"]'));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                3,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            4,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where d.appointment_outcome = 'Pitched' and
           installation_agreement_signed_date is null
       and d.current_stage_id not in (1,2,3) AND originator_id = 1 and
         (d.financier is null or d.financier != '["One Roof Energy"]' ));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                4,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
           -- case when p.custom_field_group_assignment_id = 26 then d2.intr  TODO get field from base introduction_call completed by
            case when p.custom_field_group_assignment_id = 27 then d2.proposal_nbr::integer
                when p.custom_field_group_assignment_id = 14 then (select id from flow.list_of_value where parent_id = 140
                                                                                                       and name = d2.introduction_call)
                 when p.custom_field_group_assignment_id = 61 then (select id from flow.list_of_value where parent_id = 81
                                                                                                        and name = d2.credit_check)
                 when p.custom_field_group_assignment_id = 41 then d2.panel_brand
                 when p.custom_field_group_assignment_id = 42 then d2.panel_quantity
                 when p.custom_field_group_assignment_id = 43 then d2.panel_watts
                 when p.custom_field_group_assignment_id = 44 then (select id from flow.list_of_value where parent_id = 143
                                                                                                        and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 45 then (select id from flow.list_of_value where parent_id = 115
                                                                                                        and name = d2.financier)
               --  when p.custom_field_group_assignment_id = 58 then (select id from flow.list_of_value where parent_id = 423
               --                                                                                                         and name = d2.loan_term) TODO get field from base
                 when p.custom_field_group_assignment_id = 54 then d2.number_of_promotion_payments
                else null end,
            case when p.custom_field_group_assignment_id = 46 then d2.loan_amount
                when p.custom_field_group_assignment_id = 48 then d2.interest_rate  --TODO get interest rate
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            5,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
    inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
            d.installation_agreement_signed_date is not null and (d.site_survey_scheduled_date is null or site_survey_completed_date is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                5,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
            case when p.custom_field_group_assignment_id = 17 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 7 and dce.primary_flag is true and dce.deleted is false)
                 when p.custom_field_group_assignment_id = 19 then (select id from flow.list_of_value where parent_id = 353
                                                                                                        and name = d2.site_survey_type)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SITE SURVEY*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            60,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
            d.site_survey_scheduled_date is not null and site_survey_completed_date is not null and site_survey_uploaded_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                60,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            7,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
        site_survey_uploaded_date is not null and final_design_created_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                7,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
            case when p.custom_field_group_assignment_id = 35 then d2.price_change
                when p.custom_field_group_assignment_id = 34 then d2.kwh_change
                 when   p.custom_field_group_assignment_id = 33 then (select id from blueraven.user where (first_name||' '||last_name) = d2.final_design_completed_by)
                 when p.custom_field_group_assignment_id = 75 then  d2.panel_quantity
                 when p.custom_field_group_assignment_id = 76 then  d2.panel_brand
                 when p.custom_field_group_assignment_id = 77 then  (select id from flow.list_of_value where parent_id = 143
                                                                                                         and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 74 then  d2.panel_watts
                -- when p.custom_field_group_assignment_id = 78 then  d2.1st_year_production_estimate)

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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            61,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         final_design_created_date is not null and final_design_qa_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                61,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
            case when p.custom_field_group_assignment_id = 38 then final_design_qa_feedback else null end, --TODO get this from base
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );



/*SEND FINAL DESIGN TO CUSTOMER*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            8,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         final_design_qa_date is not null and final_design_sent_to_customer_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                8,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            9,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         final_design_sent_to_customer_date is not null and ((final_design_signed_date is null or utility_bill_verified_date is null or agreement_signed_date is null) or
                                                             (financier IN ('["Cash"]') and first_cash_payment_paid_date is null)));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                9,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            62,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         final_design_signed_date is not null and plan_set_created_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                62,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
                 when p.custom_field_group_assignment_id = 70 then  d2.panel_brand
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            63,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         plan_set_created_date is not null and plan_set_qa_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                63,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
            case when p.custom_field_group_assignment_id = 66 then (select id from blueraven.user where (first_name||' '||last_name) = d2.plan_set_created_by)
                 else null end,
            case when p.custom_field_group_assignment_id = 65 then ((plan_set_qa_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*CREATE PERMIT PACK*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            10,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         ((site_survey_completed_date IS NOT NULL AND site_survey_completed_date <= (now() AT TIME ZONE 'US/Mountain') - interval '3 hours' AND
           (
                   (resurvey_required_date IS NULL OR (resurvey_required_date IS NOT NULL AND resurvey_date <= (now() AT TIME ZONE 'US/Mountain'))) AND
                   (resurvey_b_required_date IS NULL OR (resurvey_b_required_date IS NOT NULL AND resurvey_b_date <= (now() AT TIME ZONE 'US/Mountain'))) AND
                   (resurvey_c_required_date IS NULL OR (resurvey_c_required_date IS NOT NULL AND resurvey_c_date <= (now() AT TIME ZONE 'US/Mountain')))
               )
             AND
           (site_survey_photos_missing_date IS NULL OR site_survey_uploaded_date IS NOT NULL) AND
           (final_design_created_date IS NULL OR
            site_survey_verified_date IS NULL OR
            ((site_survey_uploaded_date IS NULL OR site_survey_quality_checklist IS NULL) and site_survey_completed_date::date > '2018-02-27'::date) OR
            ((price_change is null or kwh_change is null) and final_design_created_date > '2018-06-11' :: date) OR
            (utility_company = 'CO - Xcel Energy' and pv_watts_estimate is null and final_design_created_date > '2019-02-20' :: date))) or
          (site_survey_verified_date IS NOT NULL AND
          ((permit_pack_revision_requested_date IS NOT NULL
              AND permit_pack_revision_complete_date IS NULL) OR
           (permit_revision_b_requested_date IS NOT NULL AND
            permit_revision_b_complete_date IS NULL) OR (permit_revision_c_requested_date IS NOT NULL AND permit_revision_c_complete_date IS NULL) OR
           (as_built_permit_required_date is not null and as_built_permit_packet_complete_date is null) OR
           (redesign_signed_date is not null AND redesign_signed_date :: DATE >= '2019-06-11' AND
            greatest(permit_pack_complete,permit_pack_revision_complete_date,permit_revision_b_complete_date,permit_revision_c_complete_date):: DATE < redesign_signed_date :: DATE)
              ))));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                10,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                10,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                10,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                10,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            64,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         structural_analysis_required is not null and structural_analysis_complete is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                64,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            12,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         engineering_stamp_requested_date is not null and engineering_stamp_received_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                12,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            65,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where sd.id not in (1,2,3) AND originator_id = 1 and (d.financier is null or d.financier != '["One Roof Energy"]' ) and
         electrical_engineering_stamp_requested_date is not null and electrical_engineering_stamp_received_date is null);

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                65,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            13,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where ((sd.id NOT IN (2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND
             originator_id = 1 and
             final_design_signed_date is not null and
             (fl_noc_application_signature_verified_date IS NOT NULL OR d.state_id != 9) AND
             ((engineering_stamp_required is null or engineering_stamp_required = 'No') OR engineering_stamp_received_date is not null) AND
             (engineering_restamp_required_date is null  OR engineering_restamp_received_date is not null) and
             (redesign_requested_date is null OR redesign_signed_date is not null) AND
             (d.on_hold IS NULL OR d.on_hold = FALSE) AND permit_packet_submitted_date IS not NULL and
             (engineering_restamp_required_date is null or engineering_restamp_received_date is not null) and
             ((hoa_approval_required_for_permit IS NULL OR hoa_approval_required_for_permit IS FALSE OR hoa_approval_needed = 'No') OR
              hoa_approval_received_date IS NOT NULL ) and
             ((interconnection_approval_required_for_permit_submission IS NULL OR
               interconnection_approval_required_for_permit_submission IS FALSE) OR
              (nem_approved_by_utility_date IS NOT NULL)) AND
             as_built_permit_required_date IS NULL AND
             ((permit_pack_revision_complete_date IS NOT NULL
                 AND
               permit_pack_revision_submittal_scheduled_date
                   IS NULL AND
               permit_packet_submitted_date <=
               permit_pack_revision_complete_date and
               permit_revision_b_requested_date is null) --/* REVISION A */
                 OR
              permit_revision_b_complete_date IS NOT NULL and
              (permit_packet_submitted_date <= permit_revision_b_complete_date
                  AND permit_revision_b_submittal_scheduled_date IS NULL and
               permit_revision_c_requested_date is null) --/* REVISION B */
                 OR
              (permit_revision_c_complete_date IS NOT NULL and
               permit_packet_submitted_date <= permit_revision_c_complete_date and
               permit_revision_c_submittal_scheduled_date IS NULL)  )) -- /* REVISION C */
         or ((sd.id NOT IN (2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND
              (d.on_hold IS NULL OR d.on_hold = FALSE) and
              final_design_signed_date is not null and
              ((engineering_stamp_required is null or engineering_stamp_required = 'No') OR engineering_stamp_received_date is not null) AND
              (engineering_restamp_required_date is null  OR engineering_restamp_received_date is not null) and
              (redesign_requested_date is null OR redesign_signed_date is not null) and
              permit_pack_complete::date is not null and permit_packet_submitted_date is null and
              (permit_pack_revision_requested_date::date is null or permit_pack_revision_complete_date::date is not null) and
              (permit_revision_b_requested_date::date is null or permit_revision_b_complete_date::date is not null) and
              (permit_revision_c_requested_date::date is null or permit_revision_c_complete_date::date is not null) and
              ((hoa_approval_required_for_permit IS NULL OR hoa_approval_required_for_permit IS FALSE OR hoa_approval_needed = 'No') OR
               (hoa_approval_received_date IS NOT NULL)) AND
              ((interconnection_approval_required_for_permit_submission IS NULL OR
                interconnection_approval_required_for_permit_submission IS FALSE) OR
               (nem_approved_by_utility_date IS NOT NULL)))) AND

            (engineering_due_diligence_required_date IS NULL OR engineering_due_diligence_complete_date IS NOT NULL) AND
            (engineering_due_diligence_b_required_date IS NULL OR engineering_due_diligence_b_complete_date IS NOT NULL) AND
            (engineering_due_diligence_c_required_date IS NULL OR engineering_due_diligence_c_complete_date IS NOT NULL) AND
            (supply_quality_issue_review_required IS NULL OR supply_quality_issue_review_complete IS NOT NULL)

               ));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                13,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
            case when p.custom_field_group_assignment_id = 99 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 9 and dce.primary_flag is true and dce.deleted is false) else null end,
            case when p.custom_field_group_assignment_id = 100 then permit_fee
                when p.custom_field_group_assignment_id = 101 then permit_deposit_fee else null end,
            case when p.custom_field_group_assignment_id = 102 then permit_fee_paid else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                13,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
            case when p.custom_field_group_assignment_id = 99 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 9 and dce.primary_flag is true and dce.deleted is false) else null end,
            case when p.custom_field_group_assignment_id = 100 then permit_fee
                 when p.custom_field_group_assignment_id = 101 then permit_deposit_fee else null end,
            case when p.custom_field_group_assignment_id = 102 then permit_fee_paid else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                13,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
            case when p.custom_field_group_assignment_id = 99 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 9 and dce.primary_flag is true and dce.deleted is false) else null end,
            case when p.custom_field_group_assignment_id = 100 then permit_fee
                 when p.custom_field_group_assignment_id = 101 then permit_deposit_fee else null end,
            case when p.custom_field_group_assignment_id = 102 then permit_fee_paid else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                13,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
            case when p.custom_field_group_assignment_id = 99 then (select org_id from blueraven.deal_calendar_event dce where dce.deal_id = d2.id and dce.work_type_id = 9 and dce.primary_flag is true and dce.deleted is false) else null end,
            case when p.custom_field_group_assignment_id = 100 then permit_fee
                 when p.custom_field_group_assignment_id = 101 then permit_deposit_fee else null end,
            case when p.custom_field_group_assignment_id = 102 then permit_fee_paid else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*VERIFY PERMIT PACK SUBMISSION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            67,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND
            (d.on_hold IS NULL OR d.on_hold = FALSE)
         AND
         -- Ready for permit submittal verification
            ((permit_packet_submitted_date IS NOT NULL AND
              permit_packet_submitted_date < ((now() AT TIME ZONE 'US/Mountain') :: DATE) + 1 AND
              permit_pack_submittal_verified IS NULL and (permit_location is null or permit_location != 'Unknown'))
                OR
             (permit_pack_revision_submittal_date IS NOT NULL AND
              permit_pack_revision_submittal_date < ((now() AT TIME ZONE 'US/Mountain') :: DATE) + 1 AND
              permit_pack_revision_submittal_verified_date IS NULL and (permit_pack_revision_location is null or permit_pack_revision_location != 'Unknown'))
                OR
             (permit_revision_b_submittal_date IS NOT NULL AND
              permit_revision_b_submittal_date < ((now() AT TIME ZONE 'US/Mountain') :: DATE) + 1 AND
              permit_revision_b_submitted_verified_date IS NULL and (permit_revision_b_location is null or permit_revision_b_location != 'Unknown'))
                OR
             (permit_revision_c_submittal_date IS NOT NULL AND
              permit_revision_c_submittal_date < ((now() AT TIME ZONE 'US/Mountain') :: DATE) + 1 AND
              permit_revision_c_submitted_verified_date IS NULL and (permit_revision_c_location is null or permit_revision_c_location != 'Unknown')))));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                67,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                67,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                67,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                67,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            15,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and
         -- ORIGINAL PERMIT
            ((permit_pack_submittal_verified is not null and
              (permit_outcome is null OR (permit_outcome = 'Corrections Required' AND
                                          ((permit_pack_revision_requested_date is null OR permit_pack_revision_requested_date <= permit_pack_submittal_verified) AND
                                           (permit_revision_b_requested_date is null OR permit_revision_b_requested_date <= permit_pack_submittal_verified) AND
                                           (permit_revision_c_requested_date is null OR permit_revision_c_requested_date <= permit_pack_submittal_verified OR
                                            permit_revision_c_complete_date <= permit_pack_submittal_verified))) OR
               (permit_outcome = 'Approved' AND permit_approved_date is null))) OR
                -- PERMIT REVISION A
             (permit_pack_revision_submittal_verified_date is not null and
              (permit_pack_revision_outcome is null OR (permit_pack_revision_outcome = 'Corrections Required' AND permit_revision_b_requested_date is null) OR
               (permit_pack_revision_outcome = 'Approved' AND permit_pack_revision_approved_date is null))) OR
                -- PERMIT REVISION B
             (permit_revision_b_submitted_verified_date is not null and
              (permit_revision_b_outcome is null OR (permit_revision_b_outcome = 'Corrections Required' AND permit_revision_c_requested_date is null) OR
               (permit_revision_b_outcome = 'Approved' AND permit_revision_b_approved_date is null))) OR
                -- PERMIT REVISION C
             (permit_revision_c_submitted_verified_date is not null and
              (permit_revision_c_outcome is null OR permit_revision_c_outcome = 'Corrections Required') OR
              (permit_revision_c_outcome = 'Approved' AND permit_revision_c_approved_date is null)))));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                15,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                15,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                15,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                15,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            68,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' )  and originator_id = 1 and
         (d.on_hold is null or d.on_hold = false) and final_design_signed_date is not null
       AND nem_submitted_to_utility_date is null AND
         (d.utility_bill_verified_date is null OR utility_account_number is null OR
          (proof_of_howmeowners_insurance_required is true and proof_of_homeowners_insurance_obtained_date is null))));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                68,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
                                                                                                        and name = d2.proof_of_howmeowners_insurance_required) else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*READY TO SEND OR SIGN INTERCONNECTION APPLICATION*/
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            69,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND originator_id = 1 and
            (d.on_hold IS NULL OR d.on_hold = FALSE) AND
            (nem_signed_date IS NULL OR (nem_signed_date is not null and utility_company in ('IN - Duke Energy', 'OH - AEP Ohio')) and
                                        nem_approved_by_utility_date is not null and nem_approved_by_utility_date > nem_signed_date)
          and
            utility_company != 'FL - Orlando Utilities Commission (OUC)' AND
            CASE WHEN utility_company IN (
                                          'NC - Duke Power Company',
                                          'NC - Duke Energy',
                                          'WA - Puget Sound Energy (PSE)',
                                          'SC - Duke Power Company',
                                          'SC - Duke Energy',
                                          'SC - South Carolina Energy & Gas (SCE&G)',
                                          'IN - Duke Energy',
                                          'OH - AEP Ohio',
                                          'SC - Dominion Energy',
                                          'CO - Mountain Valley ELectric Association (MVEA)',
                                          'CO - Mountain View ELectric Association (MVEA)',
                                          'NV - Valley Electric Association (VEA)',
                                          'TX - Oncor',
                                          'TX - Centerpoint Energy', -- need to add
                                          'TX - TNMP', -- need to add
                                          'TX - AEP Texas', -- need to add
                                          'VA - Dominion Energy' -- need to add
                ) THEN
                     final_design_signed_date IS NOT NULL
                 WHEN utility_company IN (
                                          'ID - Rocky Mountain Power',
                                          'OR - Pacific Power',
                                          'CO - Xcel Energy',
                                          'UT - Rocky Mountain Power',
                                          'ID - Idaho Falls Power',
                                          'IN - Indianapolis Power & Light (IPL)') THEN
                     nem_approved_by_utility_date IS NOT NULL
                 WHEN utility_company IN (
                                          'FL - Duke Energy',
                                          'FL - Florida Power and Light',
                                          'FL - SECO',
                                          'FL - TECO') THEN
                     substantial_completion_approved_date IS NOT NULL
                 WHEN utility_company IN (
                     'NV - NV Energy') THEN
                     (nem_approved_by_utility_date is not null and ahj_inspection_passed_date is not null)
                 ELSE permit_pack_complete IS NOT NULL END ));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                69,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            19,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and permit_pack_complete is not null
         and (nem_signed_date is not null OR
              utility_company IN ('ID - Rocky Mountain Power','OR - Pacific Power','CO - Xcel Energy','ID - Idaho Falls Power','NV - NV Energy','UT - Rocky Mountain Power')) and
            ((proof_of_howmeowners_insurance_required is null or proof_of_howmeowners_insurance_required is false) or
             (proof_of_homeowners_insurance_obtained_date is not null)) and
            ((permit_approval_required_for_submission_to_utility is null or permit_approval_required_for_submission_to_utility is false) or
             (permit_approved_date is not null or permit_pack_revision_approved_date is not null or permit_revision_b_approved_date is not null or permit_revision_c_approved_date is not null)) and
            utility_account_number is not null and utility_bill_verified_date is not null) and ((nem_submitted_to_utility_date is null) or
                                                                                                (nem_submitted_to_utility_date is not null and nem_submitted_to_utility_date::date > '2018-09-26'::date and df.id not in (select deal_id
                                                                                                                                                                                                                          from blueraven.version_control vc where vc.document_package_type_id = 6
                                                                                                ) and
                                                                                                 d.deal_base_oid in (select deal_base_oid::integer
                                                                                                                      from blueraven.design_log_history))));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                19,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            20,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and interconnection_application_rejected is null and
            nem_submitted_to_utility_date is not null and nem_approved_by_utility_date is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                20,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            70,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and interconnection_application_rejected is not null and nem_approved_by_utility_date is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                70,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            21,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and final_design_signed_date is not null and hoa_approval_needed ='Yes' and
            hoa_contact_information is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                21,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            22,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and
            hoa_approval_needed ='Yes' and
            hoa_contact_information is not null and final_design_signed_date is not null and permit_pack_complete is not null) and
         ((hoa_request_for_approval_submitted_date is null) or (hoa_request_for_approval_submitted_date is not null
             and hoa_request_for_approval_submitted_date::date > '2018-09-26'::date and d.id not in (select deal_id
                                                                                                      from blueraven.version_control vc
                                                                                                      where vc.document_package_type_id = 7
             ) and
                                                                d.deal_base_oid in (select deal_base_oid::integer
                                                                                     from blueraven.design_log_history))));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                22,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            23,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id not in (2,3) and (d.financier is null or d.financier != '["One Roof Energy"]' ) and originator_id = 1 and
            (d.on_hold is null or d.on_hold = false) and (hoa_approval_needed is null or hoa_approval_needed = 'Yes') and hoa_request_for_approval_submitted_date is not null and hoa_approval_received_date is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                23,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            24,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (1,2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND originator_id = 1 and
            (d.on_hold IS NULL OR d.on_hold = FALSE) AND
            permit_pack_complete IS NOT NULL AND
            (final_design_signed_date IS NOT NULL OR redesign_signed_date IS NOT NULL) AND
            (redesign_requested_date is null OR redesign_signed_date is not null) AND
            site_survey_verified_date is not null and
            (
                    (resurvey_required_date IS NULL OR (resurvey_required_date IS NOT NULL AND resurvey_date <= (now() AT TIME ZONE 'US/Mountain'))) AND
                    (resurvey_b_required_date IS NULL OR (resurvey_b_required_date IS NOT NULL AND resurvey_b_date <= (now() AT TIME ZONE 'US/Mountain'))) AND
                    (resurvey_c_required_date IS NULL OR (resurvey_c_required_date IS NOT NULL AND resurvey_c_date <= (now() AT TIME ZONE 'US/Mountain')))
                ) and
            in_house_mpu_required_date is not null and in_house_mpu_permit_pack_complete_date is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                24,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            25,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (1,2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND originator_id =1 AND
            (d.on_hold IS NULL OR d.on_hold = FALSE) AND
            (final_design_signed_date IS NOT NULL OR redesign_signed_date IS NOT NULL) AND
            ((redesign_requested_date is null OR redesign_signed_date is not null)) AND
            in_house_mpu_permit_pack_complete_date is not null and in_house_mpu_permit_submittal_scheduled_date is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                25,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            26,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (1,2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND originator_id =1 AND
            (d.on_hold IS NULL OR d.on_hold = FALSE) AND
            (final_design_signed_date IS NOT NULL OR redesign_signed_date IS NOT NULL) AND
            ((redesign_requested_date is null OR redesign_signed_date is not null)) AND
            in_house_mpu_permit_submittal_date is not null and
            in_house_mpu_permit_submittal_date <= (now() AT TIME ZONE 'US/Mountain') AND
            in_house_mpu_permit_submittal_verified_date is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                26,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
    (SELECT project.id,
            27,
            (SELECT id FROM flow.company_process_step_status_type WHERE case when d.cancelled_date is null then
                                                                                     process_step_status_type = 'Active' else
                                                                                     process_step_status_type = 'Cancelled' end
                                                                    and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
            2350555 as created_by_id
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
              inner join blueraven.stage sd on sd.id = d.current_stage_id
     where (sd.id NOT IN (1,2, 3) AND (d.financier IS NULL OR d.financier != '["One Roof Energy"]') AND originator_id =1 AND
            (d.on_hold IS NULL OR d.on_hold = FALSE) AND
            (final_design_signed_date IS NOT NULL OR redesign_signed_date IS NOT NULL) AND
            ((redesign_requested_date is null OR redesign_signed_date is not null)) AND
            in_house_mpu_permit_submittal_verified_date is not null AND
            in_house_mpu_permit_approved_date is null));

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id)
        (SELECT project.id,
                27,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) AS process_step_status_id,
                2350555 as created_by_id
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
