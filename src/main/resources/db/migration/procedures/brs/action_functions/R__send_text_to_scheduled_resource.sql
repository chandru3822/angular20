-- drop function brs.send_text_to_scheduled_resource(integer, integer, integer);
CREATE OR REPLACE FUNCTION brs.send_text_to_scheduled_resource(p_pps_event_id integer, p_current_user_id integer, p_message_type_id int)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_resource_type_id int; --1 = org, 2 = user
    v_resource_id int; -- will either be a user id or an org id
    v_users_to_message bigint[]; --will be used when the resource is an org
    v_message text;
    v_time_zone_for_resource text;
    v_project_id int;
    v_appt_start_time text;
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
           case when sl.system_list_type_id = 1 then ppse.resource_id else up.user_id end --if org then resource_id, else user_id from user_position
    into v_resource_type_id,
         v_resource_id
    from flow.project_process_step_event ppse
      inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
      inner join flow.event e on pse.event_id = e.id
      inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
      inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
      inner join flow.system_list sl on sl.id = csl.system_list_id
      left join flow.user_position up on up.id = ppse.resource_id
    where ppse.id = p_pps_event_id;

    --2 = user, 1 = org
    if v_resource_type_id = 2 then
      select array[u.id]::bigint[]
      into v_users_to_message
      from flow."user" u
      where u.id = v_resource_id;
      -- also get the users timezone
      select t.timezone into v_time_zone_for_resource
      from flow.user_position up
        inner join flow.org o on up.org_id = o.id
        inner join flow.company_timezone ct on ct.id = o.company_timezone_id
        inner join flow.timezone t on t.id = ct.timezone_id
      where up.user_id = v_resource_id
        and up.primary_flag is true
        and up.archived is false;
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
      select t.timezone into v_time_zone_for_resource
      from flow.org o
        inner join flow.company_timezone ct on ct.id = o.company_timezone_id
        inner join flow.timezone t on t.id = ct.timezone_id
      where o.id = v_resource_id;
    end if;

    select pps.project_id into v_project_id
      from flow.project_process_step_event ppse
      inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
    where ppse.id = p_pps_event_id;

    --this gets the start time fields for the given pps ...which must be a pps with a schedulable custom field group
    select to_char((ppse.start_time at time zone 'UTC') at time zone coalesce(p.time_zone, v_time_zone_for_resource)::text, 'MM/DD/YYYY HH:MI am')
      into v_appt_start_time
    from flow.project_process_step_event ppse
      inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
      inner join flow.project p on pps.project_id = p.id
    where ppse.id = p_pps_event_id;

    if p_message_type_id = 1 then
      select concat('A site survey has been added to your calendar. Project: ', v_project_id, ' Date: ', v_appt_start_time) into v_message;
    end if;

  for r in
    select phone_number, u.id as user_id
    from flow."user" u
    where array[id] <@ array[v_users_to_message]
    LOOP
      if r.phone_number is not null and v_message is not null then
        insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
        values(r.user_id,
               v_message,
               (SELECT md5(random()::text || clock_timestamp()::text)::uuid),
               r.phone_number, now(), 1, p_current_user_id);
      end if;
    END LOOP;




END
$function$


