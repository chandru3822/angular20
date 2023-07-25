drop function if exists brs.send_text_to_closer(bigint, bigint, bigint);
CREATE OR REPLACE FUNCTION brs.send_text_to_closer(p_project_id bigint, p_current_user_id bigint,
                                                   p_message_type_id bigint)
  RETURNS void
  LANGUAGE plpgsql
AS
$function$
declare
  v_closer_user_id          bigint;
  v_closer_org_id           bigint;
  v_closer_phone_number     text;
  v_closer_first_name       text;
  v_contact_name            text;
  v_contact_street          text;
  v_contact_city            text;
  v_contact_state           text;
  v_appt_start_time         text;
  v_appt_end_time           text;
  v_system_size             text;
  v_installation_start_time text;
  v_project_name            text;
  v_project_phone           text;
  v_closer_position_id      bigint; --this is so we can check if the closer is a closer, manager, district, etc
  v_do_manager_send         boolean default false;
  v_manager_user_id         bigint;
  v_manager_first_name      text;
  v_manager_phone_number    text;
  v_text_message_string     text;
  v_closer_has_access       boolean;
BEGIN

  -- get the closers phone number
  -- and start and end times converted to the contact or closers time zone
  -- and contact name and address and system size (converted to text)
  select u.phone_number,
         u.first_name,
         u.id,
         o.id,
         (closer_appointment_start at time zone 'UTC') at time zone coalesce(pd.project_time_zone, t.timezone)::text,
         (closer_appointment_end at time zone 'UTC') at time zone coalesce(pd.project_time_zone, t.timezone)::text,
         pd.contact_name,
         pd.project_street1,
         pd.project_city,
         pd.project_state_abbreviation,
         pd.system_size::text,
         (pd.installation_start_time at time zone 'UTC') at time zone coalesce(pd.project_time_zone, t.timezone)::text,
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

  --check if the assigned closer is a `closer` and that the message type should send to manager
  if (v_closer_position_id = 1 AND p_message_type_id = any (array [23]::bigint[])) then
    --populate the manager's name and phone number
    select up.user_id, u.first_name, u.phone_number
      into v_manager_user_id, v_manager_first_name, v_manager_phone_number
    from flow.user_position up
           inner join flow.position p on up.position_id = p.id
           inner join flow."user" u on up.user_id = u.id
           INNER JOIN flow.company_user_status cus on cus.user_id = u.id
           INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = p.company_id
    where up.org_id = 805
      and up.position_id = 2  --only look for closer managers per carlin
      and up.primary_flag is true
      and up.archived is false
      and up.start_date < now()
      and ust.has_access is true
      and (up.end_date is null or up.end_date > now());

    v_do_manager_send = v_manager_phone_number is not null and trim(v_manager_phone_number) != '';
  end if;

  if v_closer_has_access is true and v_closer_phone_number is not null and trim(v_closer_phone_number) != '' then
    select case
             when p_message_type_id = 1 then
               -- 1 = appt scheduled
               concat('New Appointment Alert: A Closer Appointment with ', v_contact_name,
                      ' has been scheduled for you from ', v_appt_start_time, ' to ', v_appt_end_time,
                      ' regarding their home at ', v_contact_street, ', ', v_contact_city, ', ', v_contact_state, '.')

             when p_message_type_id = 2 then
               -- 2 = appt cancelled
               concat('Cancellation Alert: A Closer Appointment with ', v_contact_name, ' at ', v_appt_start_time,
                      ' to ', v_appt_end_time, ' has been cancelled.')

             when p_message_type_id = 3 then
               -- 3 = proposal complete
               concat('Proposal Alert: A proposal for ', v_contact_name, ' has been completed.')

             when p_message_type_id = 4 then
               -- 4 = proposal not complete
               concat('You have an appointment in less than 1 hour with ', v_contact_name,
                      ' and a proposal has not been completed.')

             when p_message_type_id = 5 then
               -- 5 = final design completed
               concat('Hey ', v_closer_first_name, ', a final design has been completed for project ', p_project_id, ', ', v_contact_name)

             when p_message_type_id = 6 then
               -- 6 = final design sent
               concat('Hey ', v_closer_first_name, ', a final design has been sent for project ', p_project_id, '. Please call them to review the final design: ', v_contact_name, ' (tel. ', v_project_phone, ')')

             when p_message_type_id = 7 then
               -- 7 = pre-qualified by Sunlight Financial
               concat('Hi ', v_closer_first_name,
                      ', Your next appointment has been pre-qualified by Sunlight Financial. This means the customer is only eligible for Sunlight Financial products (not GoodLeap). Please ensure that you only show proposals with Sunlight Financial products as the customer cannot obtain a GoodLeap loan through Blue Raven Solar.')

             when p_message_type_id = 8 then
               -- 8 = dispositioned as a No-Go or Low TSRF
               concat('Hi ', v_closer_first_name, ', Your project ', v_contact_name, ' at ', v_contact_street, ', ',
                      v_contact_city, ', ', v_contact_state, ' has been dispositioned as a No-Go or Low TSRF project.')

             when p_message_type_id = 9 then
               -- 9 = Project has been DQ'd
               concat('Hi ', v_closer_first_name, ', This is a notification letting you know Project ', v_contact_name,
                      ' (', p_project_id, ') has been disqualified by the proposals team.')

             when p_message_type_id = 10 then
               -- 10 = Credit score below 650
               concat('Hi ', v_closer_first_name, ',  a booking for ', v_contact_name,
                      'was completed with a loan for customers with a credit score below 650. As a reminder, this project counts towards your residual, but is not eligible for commission. Please let your sales manager know if you have any questions.')

             when p_message_type_id = 11 then
               -- 11 = proposal design completed
               -- Hello [project.owner], a proposal design has been completed for Project [project.project_name].
               concat('Hello ', v_closer_first_name, ',  a proposal design has been completed for Project ',
                      v_contact_name)

             when p_message_type_id = 12 then
               -- 12 = Installation scheduled
               concat('Hi ', v_closer_first_name, ',  The installation for ', v_contact_name, ', ', p_project_id,
                      ' has been scheduled for ', v_installation_start_time, '.  Address: ', v_contact_street, ', ',
                      v_contact_city, ', ', v_contact_state, '.  Size (kW): ', v_system_size)

             when p_message_type_id = 13 then
               -- 13 = proposals follow up
               concat('Hi ', v_closer_first_name, ', your follow-up is needed from the proposals team on project: ',
                      v_contact_name, ', ', p_project_id,
                      '. Access the open "Follow-up" process step on this account to see the needed information.')

             when p_message_type_id = 14 then
               -- 14 = change order sent to customer
               concat('A change order for ', v_contact_name, ' has been sent to the customer for review/signature')

             when p_message_type_id = 15 then
               -- 15 = change order created
               concat('A change order for ', v_contact_name, ' has been created and will be sent out soon')

             when p_message_type_id = 16 then
               -- 16 = zip code approved
               concat('The zip code approval request for ', v_contact_name, '(', p_project_id,
                      ') has been approved. Please request a new proposal design to move forward.')

             when p_message_type_id = 17 then
               -- 17 = zip code denied
               concat('The zip code approval request for ', v_contact_name, '(', p_project_id, ') has been denied')

             when p_message_type_id = 18 then
               -- 18 = proposal started
               concat('Proposal Started: The proposal for ', v_project_name, ' (', p_project_id,
                      ') has been claimed and is actively being worked on.')

             when p_message_type_id = 19 then
               -- 19 = proposal complete - project
               concat('Proposal Complete: The proposal for ', v_project_name, ' (', p_project_id, ') is complete.')

             when p_message_type_id = 20 then
               -- 20 = regen started
               concat('Regen Started: A regen for ', v_project_name, ' (', p_project_id,
                      ') has been claimed and is actively being worked on.')

             when p_message_type_id = 21 then
               -- 21 = regen completed
               concat('Regen Complete: The regen for ', v_project_name, ' (', p_project_id, ') is complete.')

             when p_message_type_id = 22 then
               -- 22 = project cancelled - fix for commissions
               concat('Hi ', v_closer_first_name, ', ', v_project_name, ' ', p_project_id,
                      ' has requested to cancel. You have 10 days from today to contact Retentions about the project to receive commission. Please call Retentions at (385) 200-3940 for help reactivating.')

             when p_message_type_id = 23 and v_do_manager_send is true then
               -- 23 = project cancelled: include manager (means we found the right match for the manager according to BR rules)
               concat('Hi ', v_closer_first_name, ' and ', v_manager_first_name, ', ', v_project_name, ' ',
                      p_project_id,
                      ' has requested to cancel. You have 10 days from today to contact Retentions about the project to receive commission. Please call Retentions at (385) 200-3940 for help reactivating.')

             when p_message_type_id = 23 and v_do_manager_send is false then
               -- 22 = project cancelled - fix for commissions (means BR wanted to send to manager but we didn't find the right match for the manager according to BR rules)
               concat('Hi ', v_closer_first_name, ', ', v_project_name, ' ', p_project_id,
                      ' has requested to cancel. You have 10 days from today to contact Retentions about the project to receive commission. Please call Retentions at (385) 200-3940 for help reactivating.')
             end
    into v_text_message_string;

    --insert the sms queue record for the closer's message
    if(v_text_message_string is not null) then
      insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id,
                                 message_sent_by_user_id, priority_level)
      values (v_closer_user_id,
              v_text_message_string,
              (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1,
              p_current_user_id, 2);
    end if;

    --insert the sms queue record for the manager's message
    if (v_do_manager_send is true) then
      insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id,
                                 message_sent_by_user_id, priority_level)
      values (v_manager_user_id,
              v_text_message_string,
              (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_manager_phone_number, now(), 1,
              p_current_user_id, 2);
    end if;
  end if;

END
$function$


