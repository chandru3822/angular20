drop function if exists brs.send_push_notification(bigint, bigint, bigint, bigint, text, text, text);
CREATE OR REPLACE FUNCTION brs.send_push_notification(p_project_id bigint, p_pps_id bigint, p_pps_event_id bigint,
                                                      p_current_user_id bigint,
                                                      p_recipient_type text,
                                                      p_title text,
                                                      p_message text)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_clean_recipient_type text;
    v_web_hyperlink text;
    v_resource_id          integer;
    v_resource_type_id     integer;
    v_recipient_user_ids   bigint[];
    v_valid_request        boolean default true;
    recipient              record;
BEGIN
    v_clean_recipient_type = trim(lower(p_recipient_type));
    v_web_hyperlink = case when p_pps_event_id is not null then
        concat('https://albatross.myblueraven.com/project/', p_project_id, '/processStep/', p_pps_id, '/event/', p_pps_event_id)
    when p_pps_id is not null then
        concat('https://albatross.myblueraven.com/project/', p_project_id, '/processStep/', p_pps_id)
    else concat('https://albatross.myblueraven.com/project/', p_project_id, '/details') end;

    if (v_clean_recipient_type = 'project owner') then
        select array_agg(closer_user_id)::bigint[]
        into v_recipient_user_ids
        from brs.project_details pd
        where pd.project_id = p_project_id
        and pd.closer_user_id is not null;
        --if the pps id or pps_event id is null then there can't be a resource and we should fail
    elsif ((v_clean_recipient_type = 'resource' or v_clean_recipient_type = 'resource superior') and p_pps_event_id is not null) then
        --get the resource and the resource type
        select ppse.resource_id, sl.system_list_type_id
        into v_resource_id, v_resource_type_id
        from flow.project_process_step_event ppse
                 inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                 inner join flow.event e on pse.event_id = e.id
                 inner join flow.custom_field cf on e.resource_custom_field_id = cf.id
                 inner join flow.company_system_list csl on cf.company_system_list_id = csl.id
                 inner join flow.system_list sl on csl.system_list_id = sl.id --system_list_type_id 1 = orgs, 2 = users
        where  ppse.id = p_pps_event_id
              and ppse.resource_id is not null;

        raise notice 'Resource ID: %', v_resource_id;
        raise notice 'Resource TYPE ID: %', v_resource_type_id;

        if (v_resource_type_id = 1) then
            --if the system list is an org, get the user id of all active users in that org
            select array_agg(up.user_id)::bigint[]
                into v_recipient_user_ids
            from flow.user_position up
                     inner join flow.position p on up.position_id = p.id
                     inner JOIN flow.company_user_status cus on cus.user_id = up.user_id
                     inner JOIN flow.user_status_type ust
                                on ust.id = cus.user_status_type_id and ust.company_id = p.company_id and
                                   ust.has_access and ust.archived is false
            --if they chose 'resource superior' when the resource is already an org, then get all the users in the parent org
            where up.org_id = case
                                  when v_clean_recipient_type = 'resource superior' then
                                      (select o.parent_org_id
                                       from flow.org o
                                       where o.id = v_resource_id)
                                  else v_resource_id end
              and up.archived is false
              and ((up.end_date is null and up.start_date <= now())
                OR now() between up.start_date and up.end_date);
        elseif (v_resource_type_id = 2 and v_clean_recipient_type = 'resource') then
            --if it is a user, get the user id from the resource id (which is a user_position_id)...double check they are still active
            select array_agg(up.user_id)::bigint[]
                into v_recipient_user_ids
            from flow.user_position up
                     inner join flow.position p on up.position_id = p.id
                     inner JOIN flow.company_user_status cus on cus.user_id = up.user_id
                     inner JOIN flow.user_status_type ust
                                on ust.id = cus.user_status_type_id and ust.company_id = p.company_id and
                                   ust.has_access and ust.archived is false
            where up.id = v_resource_id;
        elseif (v_resource_type_id = 2 and v_clean_recipient_type = 'resource superior') then
            --unless... --if they chose 'resource superior' then get all the users in the resource's primary org
            select array_agg(up.user_id)::bigint[]
            into v_recipient_user_ids
            from flow.user_position up
                     inner join flow.position p on up.position_id = p.id
                     inner JOIN flow.company_user_status cus on cus.user_id = up.user_id
                     inner JOIN flow.user_status_type ust
                                on ust.id = cus.user_status_type_id and ust.company_id = p.company_id and
                                   ust.has_access and ust.archived is false
            where up.org_id = (select up2.org_id from flow.user_position up2 where up2.id = v_resource_id);
        else
            v_valid_request = false;
        end if;
    else
        v_valid_request = false;
    end if;

    raise notice 'REcipient ids: %', v_recipient_user_ids;

    --dont do anything if we didn't find a messsage, the request is invalid, or we didn't find any recipients
    if (p_message is not null and v_valid_request is true and array_length(v_recipient_user_ids, 1) > 0) then

        FOR recipient IN SELECT u.id as user_id, u.phone_number
                         from flow.user u
                         where u.id = any ( array[ v_recipient_user_ids ] )
            LOOP
                if ( recipient.phone_number is not null and trim(recipient.phone_number) != '' ) then
                    insert into flow.push_notification_queue(title, message, web_hyperlink, send_to_user_id, phone_number, created_by_id, date_created, date_modified)
                    values (p_title, p_message, v_web_hyperlink, recipient.user_id, recipient.phone_number, p_current_user_id, now(), now());
                end if;
            END LOOP;

    end if;
END
$function$


