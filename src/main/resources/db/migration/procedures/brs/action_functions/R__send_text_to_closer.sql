drop function if exists brs.send_text_to_closer(bigint, bigint, bigint);
CREATE OR REPLACE FUNCTION brs.send_text_to_closer(p_project_id bigint, p_current_user_id bigint,
                                                   p_message_type_id bigint)
  RETURNS void
  LANGUAGE plpgsql
AS
$function$
declare
  v_closer_user_id               bigint;
  v_closer_org_id                bigint;
  v_closer_phone_number          text;
  v_closer_first_name            text;
  v_contact_name                 text;
  v_contact_street               text;
  v_contact_city                 text;
  v_contact_state                text;
  v_appt_start_time              text;
  v_appt_end_time                text;
  v_site_survey_start_time       text;
  v_system_size                  text;
  v_installation_start_time      text;
  v_project_name                 text;
  v_project_phone                text;
  v_closer_position_id           bigint; --this is so we can check if the closer is a closer, manager, district, etc
  v_do_manager_send              boolean default false;
  v_manager_user_id              bigint;
  v_manager_first_name           text;
  v_manager_phone_number         text;
  v_closer_has_access            boolean;
  v_message_type_content         text;
  v_message_type_include_manager boolean;
  dv                             record;
  vars                           jsonb;

BEGIN

  -- get the closers phone number
  -- and start and end times converted to the contact or closers time zone
  -- and contact name and address and system size (converted to text)
  select u.phone_number,
         u.first_name,
         u.id,
         o.id,
         to_char(((closer_appointment_start at time zone 'UTC') at time zone
                  coalesce(pd.project_time_zone, t.timezone)::text), 'MM/DD/YYYY HH:MI am'),
         to_char(
           ((closer_appointment_end at time zone 'UTC') at time zone coalesce(pd.project_time_zone, t.timezone)::text),
           'MM/DD/YYYY HH:MI am'),
         to_char(((pd.site_survey_start_time at time zone 'UTC') at time zone
                  coalesce(pd.project_time_zone, t.timezone)::text), 'MM/DD/YYYY HH:MI am'),
         pd.contact_name,
         pd.project_street1,
         pd.project_city,
         pd.project_state_abbreviation,
         pd.system_size::text,
         to_char(((pd.installation_start_time at time zone 'UTC') at time zone
                  coalesce(pd.project_time_zone, t.timezone)::text), 'MM/DD/YYYY HH:MI am'),
         pd.project_name,
         coalesce(pd.contact_mobile_phone, pd.contact_phone),
         up.position_id,
         ust.has_access
  into v_closer_phone_number,
    v_closer_first_name,
    v_closer_user_id,
    v_closer_org_id,
    v_appt_start_time,
    v_appt_end_time,
    v_site_survey_start_time,
    v_contact_name,
    v_contact_street,
    v_contact_city,
    v_contact_state,
    v_system_size,
    v_installation_start_time,
    v_project_name,
    v_project_phone,
    v_closer_position_id,
    v_closer_has_access
  from brs.project_details pd
         inner join flow."user" u on u.id = pd.closer_user_id
         inner join flow.user_position up on up.id = pd.closer_user_position_id
         inner join flow.org o on o.id = up.org_id
         inner join flow.company_timezone ct on ct.id = o.company_timezone_id
         inner join flow.timezone t on t.id = ct.timezone_id
         left JOIN flow.company_user_status cus on cus.user_id = u.id
         left JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = pd.company_id
  where pd.project_id = p_project_id;

  select jsonb_build_object(
           'v_closer_first_name', coalesce(v_closer_first_name, ''),
           'v_contact_name', coalesce(v_contact_name, ''),
           'v_contact_street', coalesce(v_contact_street, ''),
           'v_contact_city', coalesce(v_contact_city, ''),
           'v_contact_state', coalesce(v_contact_state, ''),
           'v_appt_start_time', coalesce(v_appt_start_time, ''),
           'v_appt_end_time', coalesce(v_appt_end_time, ''),
           'v_site_survey_start_time', coalesce(v_site_survey_start_time, ''),
           'v_system_size', coalesce(v_system_size, ''),
           'v_installation_start_time', coalesce(v_installation_start_time, ''),
           'v_project_name', coalesce(v_project_name, ''),
           'v_project_id', coalesce(p_project_id::text, ''),
           'v_project_phone', coalesce(v_project_phone, ''))
  into vars;

  select mt.content,
         mt.include_manager
  into v_message_type_content, v_message_type_include_manager
  from brs.message_type mt
  where mt.id = p_message_type_id
    and mt.archived is not true;

  --dont do anything if we didn't find a messsage
  if (v_message_type_content is not null) then
    --check if the assigned closer is a `closer` and that the message type should send to manager
    if (v_closer_position_id = 1 AND v_message_type_include_manager) then
      --populate the manager's name and phone number
      select up.user_id, u.first_name, u.phone_number
      into v_manager_user_id, v_manager_first_name, v_manager_phone_number
      from flow.user_position up
             inner join flow.position p on up.position_id = p.id
             inner join flow."user" u on up.user_id = u.id
             INNER JOIN flow.company_user_status cus on cus.user_id = u.id
             INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = p.company_id
      where up.org_id = 805
        and up.position_id = 2 --only look for closer managers per carlin
        and up.primary_flag is true
        and up.archived is false
        and up.start_date < now()
        and ust.has_access is true
        and (up.end_date is null or up.end_date > now());


      v_do_manager_send = v_manager_phone_number is not null and trim(v_manager_phone_number) != '' and
                          v_manager_first_name is not null;
      if (v_do_manager_send) then
        --add managers name key here so the replace stuff can change it later. i am tired. that seems dumb.
        v_message_type_content = replace(v_message_type_content, 'v_closer_first_name',
                                         concat('v_closer_first_name and ', v_manager_first_name));
      end if;
    end if;

    if v_closer_has_access is true and v_closer_phone_number is not null and trim(v_closer_phone_number) != '' then

      FOR dv IN SELECT * FROM jsonb_each_text(vars)
        LOOP
          v_message_type_content = replace(v_message_type_content, dv.key, dv.value);
        END LOOP;


      if (v_message_type_content is not null) then
        --insert the sms queue record for the closer's message
        insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id,
                                   message_sent_by_user_id, priority_level)
        values (v_closer_user_id,
                v_message_type_content,
                (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1,
                p_current_user_id, 2);

        --insert the sms queue record for the manager's message
        if (v_do_manager_send is true) then
          insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id,
                                     message_sent_by_user_id, priority_level)
          values (v_manager_user_id,
                  v_message_type_content,
                  (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_manager_phone_number, now(), 1,
                  p_current_user_id, 2);
        end if;
      end if;
    end if;
  end if;
END
$function$


