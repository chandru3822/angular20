-- drop function brs.send_text_to_scheduled_resource(integer, integer, integer);
CREATE OR REPLACE FUNCTION brs.send_text_to_scheduled_resource(p_project_process_step_id integer, p_current_user_id integer, p_message_type_id int)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_resource_type_id int; --1 = org, 2 = user
    v_resource_id int; -- will either be a user id or an org id
    v_users_to_message bigint[]; --will be used when the resource is an org
    v_message text;
    r record;
--     v_contact_name text;
--     v_contact_street text;
--     v_contact_city text;
--     v_contact_state text;
--     v_appt_start_time text;
--     v_appt_end_time text;
BEGIN

  --NOTE: this function will only work for process steps with a schedulable custom field group
  --3144927

    --get the resource type and id
    select sl.system_list_type_id,
           case when sl.system_list_type_id = 1 then cfv.int_value else up.user_id end
    into v_resource_type_id,
         v_resource_id
    from flow.project_process_step pps
      inner join flow.process_step ps on pps.process_step_id = ps.id
      inner join flow.project_process_step_custom_field_value cfv on pps.id = cfv.project_process_step_id
      inner join flow.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id and cfga.schedule_field_type_id = 3 -- 3 = resource
      inner join flow.custom_field_group cfg on cfg.process_step_id = ps.id and cfg.event_type_id is not null and cfg.id = cfga.custom_field_group_id
      inner join flow.custom_field cf on cf.id = cfga.custom_field_id
      inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
      inner join flow.system_list sl on sl.id = csl.system_list_id
      left join flow.user_position up on up.id = cfv.int_value
    where pps.id = p_project_process_step_id;


    if v_resource_type_id = 2 then
      select array[u.id]::bigint[]
      into v_users_to_message
      from flow."user" u
      where u.id = v_resource_id;
    else
      select array_agg(distinct up.user_id)::bigint[]
      into v_users_to_message
      from flow.user_position up
        inner join flow.position p on up.position_id = p.id
        inner join flow.company_user_status cus on cus.user_id = up.user_id
        inner join flow.user_status_type ust on cus.user_status_type_id = ust.id and ust.has_access is true
      where up.org_id = v_resource_id
        and p.company_id = 3
        and ust.archived is false
        and cus.archived is false
        and up.archived is false
        and up.primary_flag is true
        and up.start_date <= now()
        and (up.end_date is null or up.end_date >= now());
    end if;

    if p_message_type_id = 1 then
      select 'A same-day site survey has been added to your calendar.' into v_message;
    end if;

  for r in
    select phone_number
    from flow."user" u
    where array[id] <@ array[v_users_to_message]
    LOOP
      if r.phone_number is not null and v_message is not null then
        insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id)
        values(p_current_user_id,
               v_message,
               (SELECT md5(random()::text || clock_timestamp()::text)::uuid),
               r.phone_number, now(), 1);
      end if;
    END LOOP;




END
$function$


