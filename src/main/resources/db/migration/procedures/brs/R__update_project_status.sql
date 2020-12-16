CREATE OR REPLACE FUNCTION brs.update_project_status(p_project_id integer, p_status varchar)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_company_project_status_type_id      integer;
    v_company_current_project_status_type varchar;
    v_company_id                          integer;
    v_company_feature_id                  integer;
BEGIN

    select company_id
    into v_company_id
    from flow.project p
             inner join flow.contact c on c.id = p.contact_id
    where p.id = p_project_id;

    select pst.project_status_type
    into v_company_current_project_status_type
    from flow.project p
             inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
             inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
    where p.id = p_project_id;

    if v_company_id is not null then
        select cpst.id
        into v_company_project_status_type_id
        from flow.company_project_status_type cpst
                 inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
        where pst.project_status_type = p_status
          and cpst.company_id = v_company_id;

        if v_company_project_status_type_id is not null then
            update flow.project p
            set company_project_status_type_id = v_company_project_status_type_id
            where p.id = p_project_id;

            if p_status = 'Active' and v_company_current_project_status_type = 'Cancelled' then

                update brs.project_details
                set cancelled_date = null
                where project_id = p_project_id;

                update brs.project_details
                set off_hold_date = now()
                where project_id = p_project_id
                  and on_hold_date is not null
                  and off_hold_date is null;
            elsif p_status = 'Active' and v_company_current_project_status_type = 'On Hold' then
                update brs.project_details
                set off_hold_date = now()
                where project_id = p_project_id;

            elsif p_status = 'Cancelled' and v_company_current_project_status_type = 'Active' then
                update brs.project_details
                set cancelled_date = now()
                where project_id = p_project_id;
                insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id)
                select 99999999,
                       concat('Project ID ', p.id, ' for ', p.project_name, ' at ', p.street1, ', ', p.city, ', ', s.abbreviation, ' has been canceled.'),
                       (SELECT md5(random()::text || clock_timestamp()::text)::uuid),
                       (select u.phone_number from flow.user_position up
                           inner join flow."user" u on up.user_id = u.id
                           where up.id = p.user_position_id),
                       now(), 1
                from flow.project p
                    inner join flow.company_state cs on cs.id = p.company_state_id
                    inner join flow.state s on cs.state_id = s.id
                where p.id = p_project_id;
            elsif p_status = 'Cancelled' and v_company_current_project_status_type = 'On Hold' then
                update brs.project_details
                set cancelled_date = now()
                where project_id = p_project_id;
                insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id)
                select 99999999,
                       concat('Project ID ', p.id, ' for ', p.project_name, ' at ', p.street1, ', ', p.city, ', ', s.abbreviation, ' has been canceled.'),
                       (SELECT md5(random()::text || clock_timestamp()::text)::uuid),
                       (select u.phone_number from flow.user_position up
                                                       inner join flow."user" u on up.user_id = u.id
                        where up.id = p.user_position_id),
                       now(), 1
                from flow.project p
                         inner join flow.company_state cs on cs.id = p.company_state_id
                         inner join flow.state s on cs.state_id = s.id
                where p.id = p_project_id;
            elsif p_status = 'On Hold' and v_company_current_project_status_type = 'Active' then
                update brs.project_details
                set on_hold_date = now()
                where project_id = p_project_id;
            elsif p_status = 'On Hold' and v_company_current_project_status_type = 'Cancelled' then
                update brs.project_details
                set on_hold_date   = now(),
                    cancelled_date = null
                where project_id = p_project_id;
            end if;
        else
            select cf.id
            into v_company_feature_id
            from flow.company_feature cf
                     inner join flow.feature f on f.id = cf.feature_id
            where f.feature_code = 'PROCESS_STEPS'
              and cf.company_id = v_company_id;
            insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                               date_created, created_by_id)
            values (v_company_feature_id, 'Unable to Cancel project for project ' || p_project_id || '.', 1, now(),
                    99999999);
        end if;
    else
        select cf.id
        into v_company_feature_id
        from flow.company_feature cf
                 inner join flow.feature f on f.id = cf.feature_id
        where f.feature_code = 'PROCESS_STEPS'
          and cf.company_id = 3;
        insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                           date_created, created_by_id)
        values (v_company_feature_id, 'Unable to Cancel project for project ' || p_project_id || '.', 1, now(),
                99999999);

    end if;

END;
$function$
