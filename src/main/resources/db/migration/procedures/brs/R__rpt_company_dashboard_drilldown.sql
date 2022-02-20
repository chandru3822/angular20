CREATE OR REPLACE FUNCTION brs.rpt_company_dashboard_drilldown(p_custom_start_date date, p_custom_end_date date,
                                                               p_company_id integer, p_milestone_type_id integer,
                                                               p_load_partners boolean default false)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_company_ids integer[];
BEGIN
  if p_load_partners is false then
    select array_agg(id) as ids
    into v_company_ids
    from flow.company_hierarchy_filter_down(2);
  end if;
  case when p_milestone_type_id = 1 then
    RETURN QUERY select coalesce(coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]'), '[]')
                 from (
                        select concat(c.first_name, ' ', c.last_name) customer_name,
                               pd.project_id,
                               s.abbreviation                         state,
                               pd.source_name,
                               pd.first_appointment        as         date_value,
                               'Appointments Created Date' as         date_label,
                               'timestamp'                 as         date_type
                        from brs.project_details pd
                               inner join flow.project p on p.id = pd.project_id
                               inner join flow.contact c on c.id = p.contact_id
                               left outer join flow.company_state cs on cs.id = c.company_state_id
                               left outer join flow.state s on s.id = cs.state_id
                        where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                          and pd.archived is false
                          and case
                                when p_company_id is not null and p_company_id != 2 and p_company_id != 2
                                  then pd.company_id = p_company_id
                                when p_load_partners is true then
                                  pd.company_id != 3
                                else pd.company_id = any (v_company_ids)
                          end) as funnel_rows;
    when p_milestone_type_id = 2 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.first_appointment as                date_value,
                                 'Appointment Date'   as                date_label,
                                 'timestamp'          as                date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 3 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.first_appointment_pitched as        date_value,
                                 'Appointment Date'           as        date_label,
                                 'timestamp'                  as        date_type,
                                 lov.name                               additional_field_value,
                                 'Appointment Outcome'        as        additional_field_label,
                                 'text'                       as        additional_field_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                                 inner join flow.list_of_value lov on lov.id = pd.first_appointment_pitched_id
                          where ((pd.first_appointment_pitched at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 4 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name)   customer_name,
                                 pd.project_id,
                                 s.abbreviation                           state,
                                 pd.source_name,
                                 pd.installation_agreement_signed_date as date_value,
                                 'Installation Agreement Signed Date'  as date_label,
                                 'date'                                as date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.installation_agreement_signed_date at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 5 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.site_survey_verified_date as        date_value,
                                 'Site Survey Verified Date'  as        date_label,
                                 'date'                       as        date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.site_survey_verified_date at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 6 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.final_design_created_timestamp as   date_value,
                                 'Final Design Created Date'       as   date_label,
                                 'timestamp'                       as   date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.final_design_created_timestamp at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 7 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name)    customer_name,
                                 pd.project_id,
                                 s.abbreviation                            state,
                                 pd.source_name,
                                 pd.final_design_sent_to_homeowner_date as date_value,
                                 'Final Design Sent to Homeowner Date'  as date_label,
                                 'timestamp'                            as date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 8 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.final_design_signed_date  as        date_value,
                                 'Final Design Approved Date' as        date_label,
                                 'date'                       as        date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.final_design_signed_date at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 9 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.final_design_complete_date as       date_value,
                                 'Final Design Completed Date' as       date_label,
                                 'date'                        as       date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.final_design_complete_date at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 10 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.plan_set_created_date as            date_value,
                                 'Plan Set Created Date'  as            date_label,
                                 'date'                   as            date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.plan_set_created_date at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 11 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.permit_pack_complete     as         date_value,
                                 'Permit Pack Complete Date' as         date_label,
                                 'date'                      as         date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.permit_pack_complete at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 12 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name)                customer_name,
                                 pd.project_id,
                                 s.abbreviation                                        state,
                                 pd.source_name,
                                 least(((pd.online_submission_time at time zone 'UTC') at time zone 'US/Mountain'),
                                       permit_pack_submittal_verified_date) :: date as date_value,
                                 'Permit Submitted Date'                            as date_label
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where least(((pd.online_submission_time at time zone 'UTC') at time zone 'US/Mountain'),
                                      permit_pack_submittal_verified_date) :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 13 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.permit_approved_date as             date_value,
                                 'Permit Approved Date'  as             date_label,
                                 'date'                  as             date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.permit_approved_date at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 14 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.installation_scheduled     as       date_value,
                                 'Installation Scheduled Date' as       date_label,
                                 'date'                        as       date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.installation_scheduled at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 15 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.installation_start_time          as date_value,
                                 'Installation Date'                 as date_label,
                                 'timestamp'                         as date_type,
                                 pd.installation_closeout_start_time as additional_field_value,
                                 'Installation Closeout Date'        as additional_field_label,
                                 'timestamp'                         as additional_field_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where (
                              ((pd.installation_start_time at time zone 'UTC') at time zone 'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date or
                              ((pd.installation_closeout_start_time at time zone 'UTC') at time zone
                               'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date)
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 16 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.substantial_completion_date as      date_value,
                                 'Substantial Completion Date'  as      date_label,
                                 'date'                         as      date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.substantial_completion_date at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 17 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.ahj_inspection_scheduled_date   as  date_value,
                                 'AHJ Inspection Scheduled Date'    as  date_label,
                                 'date'                             as  date_type,
                                 pd.ahj_reinspection_scheduled_date as  additional_field_value,
                                 'AHJ Reinspection Scheduled'       as  additional_field_label,
                                 'date'                             as  additional_field_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where (pd.ahj_inspection_scheduled_date BETWEEN p_custom_start_date and p_custom_end_date or
                                 pd.ahj_reinspection_scheduled_date BETWEEN p_custom_start_date and p_custom_end_date)
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 18 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.ahj_inspection_start_time   as      date_value,
                                 'AHJ Inspection Date'          as      date_label,
                                 'timestamp'                    as      date_type,
                                 pd.ahj_reinspection_start_time as      additional_field_value,
                                 'AHJ Reinspection Date'        as      additional_field_label,
                                 'timestamp'                    as      additional_field_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where (((pd.ahj_inspection_start_time at time zone 'UTC') at time zone
                                  'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date or
                                 ((pd.ahj_reinspection_start_time at time zone 'UTC') at time zone
                                  'US/Mountain') :: date BETWEEN p_custom_start_date and p_custom_end_date)
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 19 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.ahj_final_inspection_verified    as date_value,
                                 'AHJ FinalInspection Verified Date' as date_label,
                                 'date'                              as date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where ((pd.ahj_final_inspection_verified at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 20 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name)                      customer_name,
                                 pd.project_id,
                                 s.abbreviation                                              state,
                                 pd.source_name,
                                 pd.verified_inspection_approval_received_by_utility_date as date_value,
                                 'Verified Inspection Approval Received by Utility Date'  as date_label,
                                 'date'                                                   as date_type,
                                 ahj_inspection_approval_submitted_date                   as additional_field_value,
                                 'AHJ Inspection Approval Submitted Date'                 as additional_field_label,
                                 'timestamp'                                              as additional_field_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where (
                              pd.verified_inspection_approval_received_by_utility_date BETWEEN p_custom_start_date and p_custom_end_date
                              or
                              pd.ahj_inspection_approval_submitted_date BETWEEN p_custom_start_date and p_custom_end_date)
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 21 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          select concat(c.first_name, ' ', c.last_name) customer_name,
                                 pd.project_id,
                                 s.abbreviation                         state,
                                 pd.source_name,
                                 pd.final_completion_submitted_date as  date_value,
                                 'Final Completion Submitted Date'  as  date_label,
                                 'date'                             as  date_type
                          from brs.project_details pd
                                 inner join flow.project p on p.id = pd.project_id
                                 inner join flow.contact c on c.id = p.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where pd.final_completion_submitted_date BETWEEN p_custom_start_date and p_custom_end_date
                            and pd.archived is false
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    when p_milestone_type_id = 22 then
      RETURN QUERY select coalesce(array_to_json(array_agg(row_to_json(funnel_rows))), '[]')
                   from (
                          with results as (
                            SELECT p.id                                                                              as project_id,
                                   p.contact_id,
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
                          select concat(c.first_name, ' ', c.last_name)   customer_name,
                                 pd.project_id,
                                 s.abbreviation                           state,
                                 pd.source_name,
                                 date_entered_queue                    as date_value,
                                 'Ready to Schedule Installation Date' as date_label,
                                 'date'                                as date_type
                          from results r
                                 inner join brs.project_details pd on pd.project_id = r.project_id
                                 inner join flow.contact c on c.id = r.contact_id
                                 left outer join flow.company_state cs on cs.id = c.company_state_id
                                 left outer join flow.state s on s.id = cs.state_id
                          where date_entered_queue between p_custom_start_date and p_custom_end_date
                            and case
                                  when p_company_id is not null and p_company_id != 2
                                    then pd.company_id = p_company_id
                                  when p_load_partners is true then
                                    pd.company_id != 3
                                  else pd.company_id = any (v_company_ids)
                            end) as funnel_rows;
    end case;
END
$function$
