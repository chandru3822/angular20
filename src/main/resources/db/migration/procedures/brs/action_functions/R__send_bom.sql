CREATE OR REPLACE FUNCTION brs.send_bom(p_project_id bigint,
                                                                      p_pps_id bigint,
                                                                      p_ppse_id bigint,
                                                                      p_user_id bigint,
                                                                      p_additional_details bigint,
                                                                      p_is_next_day_installation bigint,
                                                                      p_supplier bigint)
  returns boolean AS
$BODY$
declare
  v_matching_attachment_ids int[];
  v_org_email varchar;
  v_email_default_header text;
  v_email_default_footer text;
  v_email_sender_address varchar;
  v_email_sender_name varchar;
  v_email_subject varchar;
  v_cc_recipients varchar;
  v_email_message text;
  v_project_name text;
  v_local_start_time text;
  v_project_address text;
  v_resource_name text;
  v_coords text;
  v_state_abbr varchar;
  v_supplier_name varchar;
  v_next_day_text text;
  v_installation_time_text text;
  v_additional_details text;

BEGIN

  select 'supplychain@blueravensolar.com'
  into v_email_sender_address;

  select 'Blue Raven Supply Chain'
  into v_email_sender_name;

  select ocfv.text_value from flow.project_process_step_event_custom_field_value pcfv
                                  join flow.organization_custom_field_value ocfv on pcfv.int_value = ocfv.org_id
  where pcfv.custom_field_group_assignment_id = p_supplier
    and pcfv.project_process_step_event_id = p_ppse_id
    and ocfv.custom_field_group_assignment_id = 484
  into v_org_email;

    select o.org_name from flow.custom_field_group_assignment cfga
       join flow.project_process_step_event_custom_field_value cfv on cfga.id = cfv.custom_field_group_assignment_id
       join flow.org o on o.id = cfv.int_value where cfga.id = p_supplier
       and cfv.project_process_step_event_id = p_ppse_id
    into v_supplier_name;

    select cfv.text_value from flow.custom_field_group_assignment cfga
    join flow.project_process_step_event_custom_field_value cfv on cfga.id = cfv.custom_field_group_assignment_id
    where cfga.id = p_additional_details
      and cfv.project_process_step_event_id = p_ppse_id
    into v_additional_details;

    select
        case when
            (select lov.name = 'Yes' from flow.custom_field_group_assignment cfga
            join flow.project_process_step_event_custom_field_value cfv on cfga.id = cfv.custom_field_group_assignment_id
            join flow.list_of_value lov on cfv.int_value = lov.id
            where cfga.id = p_is_next_day_installation and cfv.project_process_step_event_id = p_ppse_id)
            then CONCAT('<mark>Next Day Installation</mark><br><br>') else '' end into v_next_day_text;


    select (select project_name from flow.project where id = p_project_id)
  into v_project_name;

  select s.abbreviation
  from flow.project p join flow.company_state cs on p.company_state_id = cs.id
      join flow.state s on s.id = cs.state_id where p.id = p_project_id
    into v_state_abbr;

    select '<!doctype html>
          <html xmlns="http://www.w3.org/1999/xhtml">
          <head>
              <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
              <meta name="viewport" content="width=device-width">
          </head>

          <body style="width: 100% !important; min-width: 100%; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; margin: 0; Margin: 0; padding: 0; -moz-box-sizing: border-box; -webkit-box-sizing: border-box; box-sizing: border-box; ">'
  into v_email_default_header;

  select '</body>
         </html>'
  into v_email_default_footer;

  select CONCAT(v_state_abbr, ' ', v_supplier_name, ', PO# ',  p_project_id)
    into v_email_subject;

  select 'supplychain@blueravensolar.com, installation.operations@blueravensolar.com'
    into v_cc_recipients;

  select date_trunc('minute', (SELECT (select start_time from flow.project_process_step_event where id = p_ppse_id) AT TIME ZONE 'UTC' AT TIME ZONE (select time_zone from flow.project where id = p_project_id)))::text
  into v_local_start_time;

    select case when
    (select (v_local_start_time)::time < '12:00')
    then (select 'This will be a morning installation.')
    else
    (select 'This will be an afternoon installation.') end
    into v_installation_time_text;


    select CONCAT(p.street1,  ' ', p.street2, ' ', p.city, ', ' , s.abbreviation, ' ', p.postal_code)
    from flow.project p join flow.company_state cs on p.company_state_id = cs.id join flow.state s on cs.state_id = s.id where p.id = p_project_id
  into v_project_address;

  select
  case when slt.id = 1 then o.org_name else u.first_name || ' ' || u.last_name end as resource
    from flow.project_process_step_event ppse
    inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
    inner join flow.event e on pse.event_id = e.id
    inner join flow.custom_field cf on e.resource_custom_field_id = cf.id
    inner join flow.company_system_list csl on cf.company_system_list_id = csl.id
    inner join flow.system_list sl on csl.system_list_id = sl.id
    inner join flow.system_list_type slt on sl.system_list_type_id = slt.id
    left join flow.user_position up on ppse.resource_id = up.id
    left join flow.user u on u.id = up.user_id
    left join flow.org o on o.id = ppse.resource_id
    where ppse.id = p_ppse_id
  into v_resource_name;

  select CONCAT(latitude, ' ', longitude) from flow.project where id = p_project_id
  into v_coords;



  select CONCAT(
  'Hi Team,
<br><br>',
v_next_day_text,
'Please see attached Bill of Materials for ', v_project_name ,'. Installation is scheduled for ', v_local_start_time,
'<br><br>',
v_installation_time_text,
'<br><br>
This will be installed by ', v_resource_name,
'<br><br>
Please confirm stock and delivery.
<br><br>
Address: ', v_project_address,
'<br><br>
Coordinates: ', v_coords,
'<br><br>
Additional Details: ', v_additional_details)
    into v_email_message;

    select array_agg(a.id)::int[] from flow.project_process_step_event_attachment ea
    join flow.attachment a on ea.attachment_id = a.id
    where project_process_step_event_id = p_ppse_id
    and a.attachment_type_id = 45
    and ea.archived = false
    and a.archived = false
    into v_matching_attachment_ids;




--   if array_length(v_matching_attachment_ids, 1) > 0 then
    if(true) then
      if(v_org_email is not null and v_email_sender_address is not null) then
        insert into flow.email_queue (user_id, subject, message, from_email,
                                      to_email, processed, from_display_name, attachment_ids, cc_recipients)
        values(p_user_id, v_email_subject, concat(v_email_default_header, v_email_message, v_email_default_footer), v_email_sender_address,
               v_org_email, false, v_email_sender_name, v_matching_attachment_ids, v_cc_recipients);

        insert into flow.project_process_step_event_custom_field_value(project_process_step_event_id,
               custom_field_group_assignment_id, date_value, created_by_id, modified_by_id)
                values (p_ppse_id, 20930, now(), p_user_id, p_user_id);

        return true;
      else
        return false;
      end if;
  else
    return false;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
