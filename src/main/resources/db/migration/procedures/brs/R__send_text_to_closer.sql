-- drop function brs.send_text_to_closer(integer, integer, integer);
CREATE OR REPLACE FUNCTION brs.send_text_to_closer(p_project_id integer, p_current_user_id integer, p_message_type_id int)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_closer_user_id int;
    v_closer_phone_number text;
    v_closer_first_name text;
    v_contact_name text;
    v_contact_street text;
    v_contact_city text;
    v_contact_state text;
    v_appt_start_time text;
    v_appt_end_time text;
BEGIN

    --get the closers phone number
    select u.phone_number, u.first_name, u.id
    into v_closer_phone_number,
         v_closer_first_name,
         v_closer_user_id
    from brs.project_details pd
        inner join flow."user" u on u.id = pd.closer_user_id
    where pd.project_id = p_project_id;

    --get the contact name
    select concat(c.first_name, ' ', c.last_name), p.street1, p.city, s.abbreviation
    into v_contact_name, v_contact_street, v_contact_city, v_contact_state
    from flow.project p
        inner join flow.contact c on c.id = p.contact_id
        inner join flow.company_state cs on p.company_state_id = cs.id
        inner join flow.state s on s.id = cs.state_id
    where p.id = p_project_id;

    -- get the start and end times converted to the contact or closers time zone
    select (closer_appointment_start at time zone 'UTC') at time zone coalesce(p.time_zone, t.timezone)::text,
           (closer_appointment_end at time zone 'UTC') at time zone coalesce(p.time_zone, t.timezone)::text
    into v_appt_start_time, v_appt_end_time
    from brs.project_details pd
             inner join flow.project p on p.id = pd.project_id
             inner join flow.user_position up on up.id = pd.closer_user_position_id
             inner join flow.org o on o.id = up.org_id
             inner join flow.company_timezone ct on ct.id = o.company_timezone_id
             inner join flow.timezone t on t.id = ct.timezone_id
    where project_id = p_project_id;


    -- the user_id was jacked up.  user_id == the user it is being sent to, message_sent_by_id = the currently logged in user
    if v_closer_phone_number is not null then
        if p_message_type_id = 1 then
            -- do the message for id 1 = appt scheduled
            -- i think message_group is just a random uuid so threads can be tracked
            insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
            values(v_closer_user_id,
            concat('New Appointment Alert: A Closer Appointment with ', v_contact_name, ' has been scheduled for you from ', v_appt_start_time, ' to ', v_appt_end_time, ' regarding their home at ', v_contact_street, ', ',v_contact_city, ', ',
                   v_contact_state, '.'),
           (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        elseif p_message_type_id = 2 then
            -- do the message for id 2 = appt cancelled
            insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
            values(v_closer_user_id,
                   concat('Cancellation Alert: A Closer Appointment with ', v_contact_name, ' at ', v_appt_start_time, ' to ', v_appt_end_time, ' has been cancelled.'),
                   (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        elseif p_message_type_id = 3 then
            -- do the message for id 3 = proposal complete
            insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
            values(v_closer_user_id,
                   concat('Proposal Alert: A proposal for ', v_contact_name, ' has been completed.'),
                   (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        elseif p_message_type_id = 4 then
            -- do the message for id 4 = proposal not complete
            insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
            values(v_closer_user_id,
                   concat('You have an appointment in less than 1 hour with ', v_contact_name, ' and a proposal has not been completed.'),
                   (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        elseif p_message_type_id = 5 then
            -- do the message for id 5 = final design completed
            insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
            values(v_closer_user_id,
                   concat('Hey ', v_closer_first_name, ', a final design has been completed for project ', v_contact_name),
                   (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        elseif p_message_type_id = 6 then
            -- do the message for id 6 = final design sent
            insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
            values(v_closer_user_id,
                   concat('Hey ', v_closer_first_name, ', a final design has been sent for project ', v_contact_name),
                   (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        elseif p_message_type_id = 7 then
          -- do the message for id 7 = pre-qualified by Sunlight Financial
          insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
          values(v_closer_user_id,
                 concat('Hi ', v_closer_first_name, ', Your next appointment has been pre-qualified by Sunlight Financial. This means the customer is only eligible for Sunlight Financial products (not GoodLeap). Please ensure that you only show proposals with Sunlight Financial products as the customer cannot obtain a GoodLeap loan through Blue Raven Solar.'),
                 (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        elseif p_message_type_id = 8 then
          -- do the message for id 8 = dispositioned as a No-Go or Low TSRF
          insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
          values(v_closer_user_id,
                 concat('Hi ', v_closer_first_name, ', Your project ', v_contact_name, ' at ', v_contact_street, ', ', v_contact_city, ', ', v_contact_state, ' has been dispositioned as a No-Go or Low TSRF project.'),
                 (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        elseif p_message_type_id = 9 then
          -- do the message for id 9 = Project has been DQ'd
          insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id, message_sent_by_user_id)
          values(v_closer_user_id,
                 concat('Hi ', v_closer_first_name, ', This is a notification letting you know Project ', v_contact_name, ' ',  p_project_id ,' has been disqualified by the proposals team.'),
                 (SELECT md5(random()::text || clock_timestamp()::text)::uuid), v_closer_phone_number, now(), 1, p_current_user_id);
        end if;
    end if;


END
$function$


