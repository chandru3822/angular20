

create temp table appointment_dates as
with one_record as (
    select resource_id,max(appointment_id) as appointment_id
    from base_mysql.appointment_contexts
    group by resource_id)
select or1.resource_id,a.start_date,a.end_date
from  base_mysql.appointments a
          inner join one_record or1 on or1.appointment_id = a.id;

create index appointment_dates_resource_id_idx
    on appointment_dates(resource_id);
drop trigger if exists update_project_details_trg on flow.project_process_step_custom_field_value;
drop  trigger if exists project_process_step_audit_trg on flow.project_process_step_custom_field_value;
drop trigger if exists update_project_process_step_custom_value_trg on flow.project_process_step;

/*SCHEDULE CLOSER APPOINTMENT*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT project.id,
            2278,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(((added_on  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
(now() + interval '1 day')
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where appointment_date is null  AND originator_id = 14
         and (d.financier IS NULL OR (d.financier != '["One Roof Energy"]' and d.financier != '["Dividend Solar"]'))
      )returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 2278
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, timestamp_value,
                                                         int_value,boolean_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 1653 then coalesce(ad.start_date,d2.appointment_date)
                 when p.custom_field_group_assignment_id = 1926 then coalesce(ad.end_date,d2.appointment_date) else null end,
             --    when p.custom_field_group_assignment_id = 25 then proposal_appoi((proposal_appointment_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')ntment_date else null end,
            case when p.custom_field_group_assignment_id = 1666 then blueraven.get_user_position_for_closer(d2.id::integer,((added_on  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')::date) else null end,
            case when p.custom_field_group_assignment_id = 11923 then d2.remote_appointment else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              left join appointment_dates ad on ad.resource_id = d2.deal_base_oid
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date)
        (SELECT project.id,
                2278,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(((added_on  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
                ((added_on  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
         ,now()
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where appointment_date is not null
           and originator_id = 14)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 2278
         and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, timestamp_value,
                                                         int_value,boolean_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 1653 then coalesce(ad.start_date,d2.appointment_date)
                 when p.custom_field_group_assignment_id = 1926 then coalesce(ad.end_date,d2.appointment_date) else null end,
             --   when p.custom_field_group_assignment_id = 25 then ((proposal_appointment_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            case when p.custom_field_group_assignment_id = 1666 then blueraven.get_user_position_for_closer(d2.id::integer,((added_on  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')::date) else null end,
            case when p.custom_field_group_assignment_id = 11923 then d2.remote_appointment else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
          left join appointment_dates ad on ad.resource_id = d2.deal_base_oid
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

drop table if exists appointment_dates;

/*CLOSER APPOINTMENT*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT project.id,
            2603,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(((added_on  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
(now() + interval '1 day')
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where appointment_date is not null
       and appointment_outcome is null
       and  originator_id = 14  and (d.financier IS NULL OR (d.financier != '["One Roof Energy"]' and d.financier != '["Dividend Solar"]')))returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 2603
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         int_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,

            case when p.custom_field_group_assignment_id = 2212 then (select id from flow.list_of_value where parent_id = 1555
                                                                                                       and name = d2.appointment_outcome)
         when p.custom_field_group_assignment_id = 17253 then (select plh.id from brs.proposal_log_history plh
                                                                        inner join blueraven.deal d3 on plh.proposal_nbr::integer = d3.proposal_nbr
                                                                                 where d2.id = d3.id and plh.project_id =d2.id limit 1)
                else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date)
        (SELECT project.id,
                2603,
                (SELECT id FROM flow.company_process_step_status_type WHERE case when d.appointment_outcome not in ('Cancelled','Missed') then
                                                                                         process_step_status_type = 'Complete' else
                                                                                         process_step_status_type = 'Cancelled' end
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(((added_on  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
                appointment_date
         ,now()
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where appointment_date is not null
           and appointment_outcome is not null
           and originator_id = 14)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 2603
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         timestamp_value,int_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 9206 then (select aci.check_in_time
                                                                      from blueraven.appointment_check_in aci
                                                                               inner join blueraven.deal d on d.deal_base_oid = aci.deal_base_oid
                                                                      where d.id = d2.id
                                                                        order by aci.id desc limit 1) else null end,
            case when p.custom_field_group_assignment_id = 2212 then (select id from flow.list_of_value where parent_id = 1555
                                                                                                       and name = d2.appointment_outcome)
                 when p.custom_field_group_assignment_id = 17253 then (select plh.id from brs.proposal_log_history plh
                                                                                             inner join blueraven.deal d3 on plh.proposal_nbr::integer = d3.proposal_nbr
                                                                      where d2.id = d3.id and plh.project_id =d2.id limit 1)
                else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*CREATE PROPOSAL*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT project.id,
            250,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(((proposal_appointment_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
                ,now()),
(now() + interval '1 day')
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where d.proposal_appointment_date is not null
       and ((d.proposal_status is not null and d.proposal_status != 'Complete') or
            (d.proposal_complete_date is null and d.proposal_status = 'Complete'))
       and (d.appointment_outcome is null or
            (d.appointment_outcome != 'Cancelled' and d.appointment_outcome != 'No Go'))
       AND originator_id = 14 and (d.financier IS NULL OR (d.financier != '["One Roof Energy"]' and d.financier != '["Dividend Solar"]')) )returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 250
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,timestamp_value,
                                                         int_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
           -- case when p.custom_field_group_assignment_id = 23 then d2.props_double_check else null end,
            case when p.custom_field_group_assignment_id = 1861 then ((proposal_complete_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
                 else null end,
            case when p.custom_field_group_assignment_id = 1952 then (select id from flow.list_of_value where parent_id = 2023
                                                                                                        and name = d2.proposal_status)
                 when p.custom_field_group_assignment_id = 6671 then (select id from flow.list_of_value where parent_id = 2101
                                                                                                         and name = d2.site_survey_type)
                 when p.custom_field_group_assignment_id = 3005 then (select up.id from blueraven.deal d
                                                                                            inner join blueraven.user u on u.first_name|| ' '||u.last_name = d.proposal_owner
                                                                                            inner join flow.user_position up on up.user_id = u.id
                                                                      where d.id = d2.id and up.position_id in (45,46,47,119) and d.proposal_owner is not null limit 1)
                 when p.custom_field_group_assignment_id = 9284 then (select lov.id
                                                                      from flow.list_of_value lov
                                                                      where parent_id = 1412
                                                                        and case when d2.appointment_outcome = 'No Go' or d2.appointment_outcome = 'Low TSRF' then
                                                                                         name = d2.appointment_outcome
                                                                                 else lov.id =  6183 end)
                else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date)
        (SELECT project.id,
                250,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(((proposal_appointment_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
                    ,now()),
                ((proposal_complete_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
                 ,now()
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where proposal_complete_date is not null
           and originator_id = 14)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 250
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,timestamp_value,
                                                         int_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 1861 then ((proposal_complete_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            case when p.custom_field_group_assignment_id = 1952 then (select id from flow.list_of_value where parent_id = 2023
                                                                                                        and name = d2.proposal_status)
                 when p.custom_field_group_assignment_id = 6671 then (select id from flow.list_of_value where parent_id = 2101
                                                                                                         and name = d2.site_survey_type)
                 when p.custom_field_group_assignment_id = 3005 then (select up.id from blueraven.deal d
                                                                                            inner join blueraven.user u on u.first_name|| ' '||u.last_name = d.proposal_owner
                                                                                            inner join flow.user_position up on up.user_id = u.id
                                                                      where d.id = d2.id and up.position_id in (45,46,47,119) and d.proposal_owner is not null limit 1)
                 when p.custom_field_group_assignment_id = 9284 then (select lov.id
                                                                      from flow.list_of_value lov
                                                                      where parent_id = 1412
                                                                        and case when d2.appointment_outcome = 'No Go' or d2.appointment_outcome = 'Low TSRF' then
                                                                                         name = d2.appointment_outcome
                                                                                 else lov.id =  6183 end)
                else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*BOOKING*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT project.id,
            1069,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(appointment_date,now()),
(now() + interval '1 day')
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where d.appointment_outcome = 'Pitched' and
           installation_agreement_signed_date is null
       AND originator_id = 14 )returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 1069
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,timestamp_value,date_value,
                                                         int_value,numeric_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 61767 then ((installation_agreement_request_submitted_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
                 else null end,
            case when p.custom_field_group_assignment_id = 1705 then installation_agreement_signed_date
                 when p.custom_field_group_assignment_id = 9258 then financial_agreement_sent_date
                 when p.custom_field_group_assignment_id = 14224 then credit_decision_date
                 when p.custom_field_group_assignment_id = 9271 then agreement_signed_date
                 else null end,
            case when p.custom_field_group_assignment_id = 1848 then (select up.id from blueraven.deal d
                                                                                          inner join blueraven.user u on u.first_name|| ' '||u.last_name = d.introduction_call_completed_by
                                                                                          inner join flow.user_position up on up.user_id = u.id
                                                                    where d.id = d2.id and up.position_id in (67,43,44,114,42) and introduction_call_completed_by is not null limit 1)
                 when p.custom_field_group_assignment_id = 13600 then (select plh.id from brs.proposal_log_history plh
                                                                    inner join blueraven.deal d3 on plh.proposal_nbr::integer = d3.proposal_nbr
                                                                    where d2.id = d3.id and plh.project_id =d2.id limit 1)
--                  when p.custom_field_group_assignment_id = 14 then (select id from flow.list_of_value where parent_id = 140
--                                                                                                         and name = d2.introduction_call)
                 when p.custom_field_group_assignment_id = 13847 then (select id from flow.list_of_value where parent_id = 1659
                                                                                                        and name = d2.credit_check)
                 when p.custom_field_group_assignment_id = 9466 then (select id from flow.list_of_value where parent_id = 1867
                                                                                                        and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 9726 then d2.panel_quantity
                 when p.custom_field_group_assignment_id = 9804 then d2.panel_watts
                 when p.custom_field_group_assignment_id = 1887 then (select id from flow.list_of_value where parent_id = 1789
                                                                                                        and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 15238 then (select id from flow.list_of_value where parent_id = 2257
                                                                                                         and name = d2.financier :: JSON #>> '{0}')
                 when p.custom_field_group_assignment_id = 15264 then (select id from flow.list_of_value where parent_id = 2075
                                                                                                         and name = d2.secondary_financier)
                 when p.custom_field_group_assignment_id = 13886 then (select id from flow.list_of_value where parent_id = 2192
                                                                                                        and name::integer = d2.loan_term)
                 when p.custom_field_group_assignment_id = 15303 then d2.number_of_promotion_payments
                 when p.custom_field_group_assignment_id = 10064 then d2.led_lightbulb_quantity
                 when p.custom_field_group_assignment_id = 10077 then d2.smart_thermostat_quantity
                 when p.custom_field_group_assignment_id = 10207 then (select id from flow.list_of_value where parent_id = 1984
                                                                                                         and name = d2.base_product)
                 when p.custom_field_group_assignment_id = 13145 then (select id from flow.list_of_value where parent_id = 1737
                                                                                                          and name = d2.hoa_approval_needed)
                 else null end,
            case when p.custom_field_group_assignment_id = 13873 then d2.loan_amount
                 when p.custom_field_group_assignment_id = 2067 then d2.interest_rate
                 when p.custom_field_group_assignment_id = 2095 then d2.total_system_price
                 when p.custom_field_group_assignment_id = 9791 then d2.system_size
                 when p.custom_field_group_assignment_id = 14237 then d2.referral_promotion_amount
                 when p.custom_field_group_assignment_id = 2082 then d2.total_promotion_amount
                 when p.custom_field_group_assignment_id = 13860 then d2.total_cash_down_payment
                 when p.custom_field_group_assignment_id = 2108 then d2.total_ancillary_cost_with_fees
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );

with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date)
        (SELECT project.id,
                1069,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(appointment_date,now()),
                installation_agreement_signed_date
         ,now()
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
           (installation_agreement_signed_date is not null)
           and originator_id = 14)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 1069
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,timestamp_value,date_value,
                                                         int_value,numeric_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 6177 then ((installation_agreement_request_submitted_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
                 else null end,
            case when p.custom_field_group_assignment_id = 1705 then installation_agreement_signed_date
                 when p.custom_field_group_assignment_id = 9258 then financial_agreement_sent_date
                 when p.custom_field_group_assignment_id = 14224 then credit_decision_date
                 when p.custom_field_group_assignment_id = 9271 then agreement_signed_date
                 else null end,
            case when p.custom_field_group_assignment_id = 1848 then (select up.id from blueraven.deal d
                                                                                          inner join blueraven.user u on u.first_name|| ' '||u.last_name = d.introduction_call_completed_by
                                                                                          inner join flow.user_position up on up.user_id = u.id
                                                                    where d.id = d2.id and up.position_id in (67,43,44,114,42) and introduction_call_completed_by is not null limit 1)
                 when p.custom_field_group_assignment_id = 13600 then (select plh.id from brs.proposal_log_history plh
                                                                    inner join blueraven.deal d3 on plh.proposal_nbr::integer = d3.proposal_nbr
                                                                    where d2.id = d3.id and plh.project_id =d2.id limit 1)
                --                  when p.custom_field_group_assignment_id = 14 then (select id from flow.list_of_value where parent_id = 140
--                                                                                                         and name = d2.introduction_call)
                 when p.custom_field_group_assignment_id = 13847 then (select id from flow.list_of_value where parent_id = 1659
                                                                                                        and name = d2.credit_check)
                 when p.custom_field_group_assignment_id = 9466 then (select id from flow.list_of_value where parent_id = 1867
                                                                                                        and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id = 9726 then d2.panel_quantity
                 when p.custom_field_group_assignment_id = 9804 then d2.panel_watts
                 when p.custom_field_group_assignment_id = 1887 then (select id from flow.list_of_value where parent_id = 1789
                                                                                                        and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id = 15238 then (select id from flow.list_of_value where parent_id = 2257
                                                                                                         and name = d2.financier :: JSON #>> '{0}')
                 when p.custom_field_group_assignment_id = 15264 then (select id from flow.list_of_value where parent_id = 2075
                                                                                                         and name = d2.secondary_financier)
                 when p.custom_field_group_assignment_id = 13886 then (select id from flow.list_of_value where parent_id = 2192
                                                                                                        and name::integer = d2.loan_term)
                 when p.custom_field_group_assignment_id = 15303 then d2.number_of_promotion_payments
                 when p.custom_field_group_assignment_id = 10064 then d2.led_lightbulb_quantity
                 when p.custom_field_group_assignment_id = 10077 then d2.smart_thermostat_quantity
                 when p.custom_field_group_assignment_id = 10207 then (select id from flow.list_of_value where parent_id = 1984
                                                                                                         and name = d2.base_product)
                 when p.custom_field_group_assignment_id = 13145 then (select id from flow.list_of_value where parent_id = 1737
                                                                                                          and name = d2.hoa_approval_needed)
                 else null end,
            case when p.custom_field_group_assignment_id = 13873 then d2.loan_amount
                 when p.custom_field_group_assignment_id = 2069 then d2.interest_rate
                 when p.custom_field_group_assignment_id = 2095 then d2.total_system_price
                 when p.custom_field_group_assignment_id = 9881 then d2.system_size
                 when p.custom_field_group_assignment_id = 14237 then d2.referral_promotion_amount
                 when p.custom_field_group_assignment_id = 2082 then d2.total_promotion_amount
                 when p.custom_field_group_assignment_id = 13860 then d2.total_cash_down_payment
                 when p.custom_field_group_assignment_id = 2108 then d2.total_ancillary_cost_with_fees
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SCHEDULE SITE SURVEY*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT p.id,
            263,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(installation_agreement_signed_date,now()),
(now() + interval '1 day')
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
     where   originator_id = 14 and (d.financier IS NULL OR (d.financier != '["One Roof Energy"]' and d.financier != '["Dividend Solar"]')) and
             d.installation_agreement_signed_date is not null and
              (d.site_survey_scheduled_date is null or site_survey_completed_date is null))returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 263
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
                -- when p.custom_field_group_assignment_id = 19 then (select id from flow.list_of_value where parent_id = 353
                 --                                                                                       and name = d2.site_survey_type)
                -- else null end,
            case when p.custom_field_group_assignment_id = 11533 then d2.site_survey_scheduled_date else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date,migrated_org_id,migrated_start_time,migrated_end_time)
        (with deals as (
            SELECT d.id,((site_survey_completed_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') as complete_date,dce2.org_id,
                   coalesce(dce2.start_time,((site_survey_completed_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')) as start_time,
                   coalesce(dce2.end_time,((site_survey_completed_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')) as end_time
            FROM flow.project
                     INNER JOIN blueraven.deal d
                                ON project.id = d.id
                     left join blueraven.deal_calendar_event dce2 on dce2.deal_id = d.id
                and site_survey_completed_date::date = (start_time::date AT TIME ZONE 'UTC' AT TIME ZONE 'US/Mountain')::date
                and dce2.deleted is false and work_type_id = 7
            where
                site_survey_completed_date is not null
              and originator_id = 14
            union all
            select deal_id,dce.updated as complete_date,dce.org_id,dce.start_time,dce.end_time
            from blueraven.deal_calendar_event dce
                     inner join blueraven.deal d on d.id = dce.deal_id
            where  originator_id = 14 and work_type_id = 7 and deleted is false
              and (d.site_survey_completed_date::date != (start_time::date AT TIME ZONE 'UTC' AT TIME ZONE 'US/Mountain')::date
                or d.site_survey_completed_date is null))
         SELECT project.id,
                263,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(installation_agreement_signed_date,now()),
                d1.complete_date
         ,date_trunc('second', coalesce(complete_date,now())::timestamp)+ ((random() * 1000 ) + 1) * interval '1 milliseconds',
                d1.org_id,
                d1.start_time,
                d1.end_time
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
                  inner join deals d1 on d1.id =d.id)returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 263
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,timestamp_value,
                                                         int_value,date_value, date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 1497 then P1.migrated_start_time
                 when p.custom_field_group_assignment_id = 1510 then p1.migrated_end_time else null end,
            case when p.custom_field_group_assignment_id = 1523 then p1.migrated_org_id
                -- when p.custom_field_group_assignment_id = 19 then (select id from flow.list_of_value where parent_id = 353
                --                                                                                        and name = d2.site_survey_type)
                 else null end,
            case when p.custom_field_group_assignment_id = 11533 then d2.site_survey_scheduled_date else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SITE SURVEY*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT project.id,
            484,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(((site_survey_completed_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
(now() + interval '1 day')
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where originator_id = 14 and (d.financier IS NULL OR (d.financier != '["One Roof Energy"]' and d.financier != '["Dividend Solar"]')) and
            d.site_survey_scheduled_date is not null and site_survey_completed_date is not null and site_survey_uploaded_date is null)returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 484
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 1549 then ((site_survey_uploaded_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date)
        (SELECT project.id,
                484,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(((site_survey_completed_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
                ((site_survey_uploaded_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
         ,now()
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             site_survey_uploaded_date is not null
           and originator_id = 14)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 484
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 1549 then ((site_survey_uploaded_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*CREATE FINAL DESIGN*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT p.id,
            276,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(((site_survey_completed_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
(now() + interval '1 day')
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
     where originator_id = 14 and (d.financier IS NULL OR (d.financier != '["One Roof Energy"]' and d.financier != '["Dividend Solar"]'))
       and (retrofit IS NULL or retrofit = FALSE) and
                                   site_survey_completed_date IS NOT NULL AND site_survey_completed_date <= (now() AT TIME ZONE 'US/Mountain')::date- interval '3 hours' AND
                                   (
                                           (resurvey_required_date IS NULL OR (resurvey_required_date IS NOT NULL AND resurvey_date <= (now() AT TIME ZONE 'US/Mountain'))) AND
                                           (resurvey_b_required_date IS NULL OR (resurvey_b_required_date IS NOT NULL AND resurvey_b_date <= (now() AT TIME ZONE 'US/Mountain'))) AND
                                           (resurvey_c_required_date IS NULL OR (resurvey_c_required_date IS NOT NULL AND resurvey_c_date <= (now() AT TIME ZONE 'US/Mountain')))
                                       ) AND
                                   (site_survey_photos_missing_date IS NULL OR site_survey_uploaded_date IS NOT NULL) AND
                                   (final_design_created_date IS NULL OR
                                    site_survey_verified_date IS NULL OR
                                    ((site_survey_uploaded_date IS NULL OR site_survey_quality_checklist IS NULL) and site_survey_completed_date::date > '2018-02-27'::date) OR
                                    ((price_change is null or kwh_change is null) and final_design_created_date > '2018-06-11' :: date) OR
                                    (utility_company = 'CO - Xcel Energy' and pv_watts_estimate is null and final_design_created_date > '2019-02-20' :: date))) returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 276
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,
                                                         int_value,int_array_value,timestamp_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 1731 then ((site_survey_photos_missing_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
                 when p.custom_field_group_assignment_id = 12885 then site_survey_brs_no_show
                 when p.custom_field_group_assignment_id = 1692 then ((site_survey_verified_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            case when p.custom_field_group_assignment_id = 2030 then (select id from flow.list_of_value where parent_id = 1971
                                                                                                        and name = d2.price_change)
                 when p.custom_field_group_assignment_id = 2017 then (select id from flow.list_of_value where parent_id = 1802
                                                                                                        and name = d2.kwh_change)
                 when   p.custom_field_group_assignment_id = 1757 then (select up.id from blueraven.deal d
                                                                                            inner join blueraven.user u on u.first_name|| ' '||u.last_name = d.final_design_completed_by
                                                                                            inner join flow.user_position up on up.user_id = u.id
                                                                      where d.id = d2.id and up.position_id in (24,25,26) and d.final_design_completed_by is not null limit 1)
                 else null end,
            case when p.custom_field_group_assignment_id = 1939 then (select array_agg(id)
                                                                    from flow.list_of_value
                                                                    where parent_id = 2088 and
                                                                            name in (
                                                                            select  * from
                                                                                json_array_elements_text((select site_survey_quality_checklist::json from blueraven.deal
                                                                                                          where site_survey_quality_checklist is not null and
                                                                                                                  id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 1744 then ((final_design_created_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            case when p.custom_field_group_assignment_id = 13184 then d2.site_survey_quality_issue
                 when p.custom_field_group_assignment_id = 8829 then  d2.pv_watts_estimate else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date)
        (SELECT project.id,
                276,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(((site_survey_completed_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
                ((final_design_created_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
         ,now()
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             final_design_created_date is not null
           and originator_id = 14)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 276
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,date_value,
                                                         int_value,int_array_value,timestamp_value,text_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 1732 then ((site_survey_photos_missing_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
                 when p.custom_field_group_assignment_id = 12885 then site_survey_brs_no_show
                 when p.custom_field_group_assignment_id = 1692 then ((site_survey_verified_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            case when p.custom_field_group_assignment_id = 2030 then (select id from flow.list_of_value where parent_id = 1971
                                                                                                        and name = d2.price_change)
                 when p.custom_field_group_assignment_id = 2017 then (select id from flow.list_of_value where parent_id = 1802
                                                                                                        and name = d2.kwh_change)
                 when   p.custom_field_group_assignment_id = 1757 then (select up.id from blueraven.deal d
                                                                                            inner join blueraven.user u on u.first_name|| ' '||u.last_name = d.final_design_completed_by
                                                                                            inner join flow.user_position up on up.user_id = u.id
                                                                      where d.id = d2.id and up.position_id in (24,25,26) and d.final_design_completed_by is not null limit 1)
                 else null end,
            case when p.custom_field_group_assignment_id = 1939 then (select array_agg(id)
                                                                    from flow.list_of_value
                                                                    where parent_id = 2088 and
                                                                            name in (
                                                                            select  * from
                                                                                json_array_elements_text((select site_survey_quality_checklist::json from blueraven.deal
                                                                                                          where site_survey_quality_checklist is not null and
                                                                                                                  id = d2.id)))) else null end,
            case when p.custom_field_group_assignment_id = 1744 then ((final_design_created_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            case when p.custom_field_group_assignment_id = 13184 then d2.site_survey_quality_issue
                 when p.custom_field_group_assignment_id = 8829 then  d2.pv_watts_estimate else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );

/*SEND FINAL DESIGN TO CUSTOMER*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT p.id,
            640,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(((final_design_qa_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'), now()),
(now() + interval '1 day')
     from flow.project p
              inner join blueraven.deal d on d.id = p.id
     where originator_id = 14 and (d.financier IS NULL OR (d.financier != '["One Roof Energy"]' and d.financier != '["Dividend Solar"]'))
       and  final_design_qa_date is not null and final_design_sent_to_customer_date is null
         AND redesign_requested_date is null AND
            (regen_requested_date IS NULL OR regen_ready_to_send_date is not null) AND
            (engineering_review_required_date is null OR engineering_review_complete_date is not null))returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 640
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,timestamp_value,numeric_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case --when p.custom_field_group_assignment_id = 710 then credit_decision_date
                 when p.custom_field_group_assignment_id = 9544 then financial_agreement_sent_date else null end,
            case when p.custom_field_group_assignment_id = 1601 then ((final_design_sent_to_customer_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            case when p.custom_field_group_assignment_id = 10012 then d2.system_size
                 when p.custom_field_group_assignment_id = 10038 then d2.referral_promotion_amount
                 when p.custom_field_group_assignment_id = 10051 then d2.total_ancillary_cost_with_fees
                 when p.custom_field_group_assignment_id = 10116 then d2.total_system_price
                 when p.custom_field_group_assignment_id = 10103 then d2.total_promotion_amount
                 when p.custom_field_group_assignment_id = 12365 then d2.loan_amount
                 when p.custom_field_group_assignment_id = 12352 then d2.total_cash_down_payment
                 else null end,
            case when p.custom_field_group_assignment_id = 10129 then (select id from flow.list_of_value where parent_id = 1984
                                                                                                        and name = d2.base_product)
                 when p.custom_field_group_assignment_id =11403 then (select plh.id from brs.proposal_log_history plh
                                                                                             inner join blueraven.deal d3 on plh.proposal_nbr::integer = d3.proposal_nbr
                                                                                             where d2.id = d3.id and plh.project_id =d2.id limit 1)
                 when p.custom_field_group_assignment_id =10818 then (select id from flow.list_of_value where parent_id = 1789
                                                                                                        and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id =9830 then d2.number_of_promotion_payments
                 when p.custom_field_group_assignment_id =10025 then d2.first_year_production_estimate
                 when p.custom_field_group_assignment_id =12339 then (select id from flow.list_of_value where parent_id = 2075
                                                                                                        and name = d2.secondary_financier)
                 when p.custom_field_group_assignment_id =9999 then panel_watts
                 when p.custom_field_group_assignment_id =9986 then panel_quantity
                 when p.custom_field_group_assignment_id =12378 then (select id from flow.list_of_value where parent_id = 2192
                                                                                                        and name::integer = d2.loan_term)
--                  when p.custom_field_group_assignment_id =709 then (select id from flow.list_of_value where parent_id = 81
--                                                                                                         and name = d2.credit_check)
                 when p.custom_field_group_assignment_id =9971 then (select id from flow.list_of_value where parent_id = 1867
                 and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id =12469 then number_of_arrays::integer
                 when p.custom_field_group_assignment_id =12690 then max_pitch::integer
                 when p.custom_field_group_assignment_id =10142 then (select id from flow.list_of_value where parent_id = 2257
                                                                                                        and name = d2.financier :: JSON #>> '{0}')
                 when p.custom_field_group_assignment_id =17277 then (select design_nbr
                                                                      from blueraven.version_control vc
                                                                               inner join blueraven.design_log dl on dl.id = log_id
                                                                      where document_package_type_id = 3
                                                                        and is_active is true
                                                                        and log_type_id = 2
                                                                        and vc.deal_id = d2.id limit 1)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date)
        (SELECT project.id,
                640,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(((final_design_qa_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'), now()),
                ((final_design_sent_to_customer_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
         ,now()
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where
             final_design_sent_to_customer_date is not null
           and originator_id = 14)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 640
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,timestamp_value,numeric_value,int_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case --when p.custom_field_group_assignment_id = 710 then credit_decision_date
                 when p.custom_field_group_assignment_id = 9544 then financial_agreement_sent_date else null end,
            case when p.custom_field_group_assignment_id = 1601 then ((final_design_sent_to_customer_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC') else null end,
            case when p.custom_field_group_assignment_id = 10012 then d2.system_size
                 when p.custom_field_group_assignment_id = 10038 then d2.referral_promotion_amount
                 when p.custom_field_group_assignment_id = 10051 then d2.total_ancillary_cost_with_fees
                 when p.custom_field_group_assignment_id = 10116 then d2.total_system_price
                 when p.custom_field_group_assignment_id = 10103 then d2.total_promotion_amount
                 when p.custom_field_group_assignment_id = 12365 then d2.loan_amount
                 when p.custom_field_group_assignment_id = 12352 then d2.total_cash_down_payment
                 else null end,
            case when p.custom_field_group_assignment_id =10129 then (select id from flow.list_of_value where parent_id = 1984
                                                                                                        and name = d2.base_product)
                 when p.custom_field_group_assignment_id =11403 then (select plh.id from brs.proposal_log_history plh
                                                                     inner join blueraven.deal d3 on plh.proposal_nbr::integer = d3.proposal_nbr
                                                                     where d2.id = d3.id and plh.project_id =d2.id limit 1)
                 when p.custom_field_group_assignment_id =10818 then (select id from flow.list_of_value where parent_id = 1789
                                                                                                        and name = d2.inverter_brand)
                 when p.custom_field_group_assignment_id =9830 then d2.number_of_promotion_payments
                 when p.custom_field_group_assignment_id =10025 then d2.first_year_production_estimate
                 when p.custom_field_group_assignment_id =12339 then (select id from flow.list_of_value where parent_id = 2075
                                                                                                        and name = d2.secondary_financier)
                 when p.custom_field_group_assignment_id =9999 then panel_watts
                 when p.custom_field_group_assignment_id =9986 then panel_quantity
                 when p.custom_field_group_assignment_id =12378 then (select id from flow.list_of_value where parent_id = 2192
                                                                                                        and name::integer = d2.loan_term)
--                  when p.custom_field_group_assignment_id =709 then (select id from flow.list_of_value where parent_id = 81
--                                                                                                         and name = d2.credit_check)
                 when p.custom_field_group_assignment_id =9973 then (select id from flow.list_of_value where parent_id = 1867
                                                                                                        and name = d2.panel_brand)
                 when p.custom_field_group_assignment_id =12469 then number_of_arrays::integer
                 when p.custom_field_group_assignment_id =12690 then max_pitch::integer
                 when p.custom_field_group_assignment_id =10142 then (select id from flow.list_of_value where parent_id = 2257
                                                                                                        and name = d2.financier :: JSON #>> '{0}')
                 when p.custom_field_group_assignment_id =17277 then (select design_nbr
                                                                      from blueraven.version_control vc
                                                                               inner join blueraven.design_log dl on dl.id = log_id
                                                                      where document_package_type_id = 3
                                                                        and is_active is true
                                                                        and log_type_id = 2
                                                                        and vc.deal_id = d2.id limit 1)
                 else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join process_step1 p1 on p1.project_id = d2.id
              cross join p
    );


/*Pending FINAL DESIGN Approval*/
with active_step as (
INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created, migrated_created_date)
    (SELECT project.id,
        1108,
            (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Active'
                                                                    and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
            2350555 as created_by_id,
            coalesce(((final_design_sent_to_customer_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
(now() + interval '1 day')
     FROM flow.project
              INNER JOIN blueraven.deal d
                         ON project.id = d.id
     where final_design_sent_to_customer_date is not null
       and
         (final_design_signed_date is null OR
          ((agreement_signed_date is null OR countersign_date is null) AND
           (d.financier = '["Mosaic"]' OR d.financier = '["LoanPal"]')))
       AND originator_id = 14)returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id =1108
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 6437 then final_design_signed_date
                 when p.custom_field_group_assignment_id = 15381 then agreement_signed_date
                 when p.custom_field_group_assignment_id = 16707 then countersign_date else null end,
            now(),now(),2350555,2350555
     from blueraven.deal d2
              inner join active_step p1 on p1.project_id = d2.id
              cross join p
    );


with process_step1 as (
    INSERT INTO flow.project_process_step (project_id, process_step_id, company_process_step_status_type_id, created_by_id,date_created,process_step_complete_date,migrated_created_date)
        (SELECT project.id,
                1108,
                (SELECT id FROM flow.company_process_step_status_type WHERE process_step_status_type = 'Complete'
                                                                        and company_id = (select id from flow.company where company_name = 'Smart Money Solar')) AS process_step_status_id,
                2350555 as created_by_id,
                coalesce(((final_design_sent_to_customer_date  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC'),now()),
                greatest(final_design_signed_date,agreement_signed_date)
         ,now()
FROM flow.project
                  INNER JOIN blueraven.deal d
                             ON project.id = d.id
         where final_design_signed_date is not null AND
             ((agreement_signed_date is not null and countersign_date is not null) OR
              ((d.financier != '["Mosaic"]' AND d.financier != '["LoanPal"]') OR d.financier is null))
           and originator_id = 14)
        returning *),
     p as (
         select cfga.id as custom_field_group_assignment_id,cf.field_name,dt.data_type,dt.id as data_type_id
         from flow.custom_field_group_assignment cfga
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                  inner join flow.data_type dt on dt.id = cdt.data_type_id
         where cfg.process_step_id = 1108
           and cf.archived is false and cfg.archived is false and cfga.archived is false
     )
insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id,
                                                         date_value,
                                                         date_created, date_modified, created_by_id, modified_by_id)
    (select p1.id,p.custom_field_group_assignment_id,
            case when p.custom_field_group_assignment_id = 6437 then final_design_signed_date
                 when p.custom_field_group_assignment_id = 15381 then agreement_signed_date
                 when p.custom_field_group_assignment_id = 16707 then countersign_date else null end,
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


DO
$do$
declare
    r record;
    BEGIN
       for r in with update_main as(
           select project_id,process_step_id
           from flow.project_process_step
           group by project_id, process_step_id
           having count(1) >1),
                     max_day as (
                         select max(migrated_created_date)as date_created,pp2.project_id,pp2.process_step_id
                         from flow.project_process_step pp2
                                  inner join update_main um2 on um2.project_id = pp2.project_id and um2.process_step_id = pp2.process_step_id
                         group by pp2.project_id,pp2.process_step_id
                     ),
                     id_to_update as(
                         select id
                         from flow.project_process_step pp3
                                  inner join max_day md on md.date_created = pp3.migrated_created_date and md.project_id = pp3.project_id and md.process_step_id = pp3.process_step_id
                     )select * from id_to_update
            LOOP
               update flow.project_process_step pps
               set main = true
               where r.id = pps.id;
            END LOOP;
    END
$do$;


CREATE TRIGGER update_project_details_trg
    after INSERT or update
    ON flow.project_process_step_custom_field_value
    FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_details_process_steps();

CREATE TRIGGER update_project_process_step_custom_value_trg
    after INSERT or update
    ON flow.project_process_step
    FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_process_step_custom_value();
