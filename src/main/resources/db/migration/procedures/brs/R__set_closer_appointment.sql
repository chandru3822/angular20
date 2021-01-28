-- drop function flow.set_closer_appointment(integer, integer, timestamp, int[])
CREATE OR REPLACE FUNCTION flow.set_closer_appointment(p_project_id integer,
                                                       p_current_user_id integer,
                                                       p_project_process_step_id integer,
                                                       p_appointment_start_time timestamp,
                                                       p_users integer array)
    RETURNS table
            (
                success                boolean,
                user_id                integer,
                appointment_start_time timestamp,
                appointment_end_time   timestamp,
                user_full_name         text,
                user_email             text
            )
AS
$BODY$
declare
    v_user_id                                    integer;
    v_project_process_step_id                    integer;
    v_project_process_step_custom_field_value_id integer;
    v_default_appointment_length                 integer;
    v_user_already_assigned                      bigint;
    v_user_full_name                             text;
    v_user_email                                 text;
    v_user_position_id                           integer;
    v_process_step_id                            integer;
    v_postal_code_zone_id                        integer;
BEGIN

    select process_step_id
    into v_process_step_id
    from flow.project_process_step pps
    where id = p_project_process_step_id;

    if v_process_step_id != 1 then
        insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                           date_created, created_by_id)
        values (327, 'Process Step ID does not equal 1 for  ' || p_project_id || '.', 1, now(),
                99999999);
        raise exception 'Unable to schedule closer appointment.  Call support to complete.';
    end if;

    select pcz.id
    into v_postal_code_zone_id
    from flow.project p
             inner join flow.postal_code pc on pc.postal_code = p.postal_code and pc.archived is false
             inner join flow.postal_code_zone pcz
                        on pcz.id = pc.postal_code_zone_id and pcz.archived is false
             inner join flow.postal_code_zone_user pczu
                        on pczu.postal_code_zone_id = pcz.id and pczu.postal_code_zone_user_type_id = 1 and
                           pczu.archived is false
    where p.id = p_project_id;


    if array_length(p_users, 1) < 2 then
        select p_users[1]
        into v_user_id;
        insert into brs.set_closer_appointment_audit(project_id, user_id, project_process_step_id,
                                                     distance_from_actual_to_target, appointment_start_date,
                                                     is_only_user_available,
                                                     created_date, available_users, created_by_id)
        values (p_project_id, v_user_id, p_project_process_step_id, 0, p_appointment_start_time, true, now(), p_users,
                p_current_user_id);
    else
        --   select p_users[1]
        --   into v_user_id;
        insert into brs.set_closer_appointment_audit(project_id, user_id, project_process_step_id,
                                                     distance_from_actual_to_target, appointment_start_date,
                                                     total_lead_allocation, actual_lead_allocation, score,
                                                     lead_gen_num, lead_gen_den, self_gen, total_avail,
                                                     appointment_count_with_interval, appointment_count, created_date,
                                                     available_users, created_by_id,manual_allocation)
            (
                select p_project_id,t.user_id,p_project_process_step_id,
                       t.distance_from_actual_to_target,p_appointment_start_time,
                       t.total_lead_allocation,t.actual_lead_allocation,t.score,
                       t.lead_gen_num,t.lead_gen_den,t.self_gen,t.avail,t.appointment_count_with_interval,
                       t.appointment_count,now(),p_users,p_current_user_id,t.manual_allocation
                from brs.get_total_lead_allocation(v_postal_code_zone_id,true) as t
            );

        select scau.user_id
        into v_user_id
        from brs.set_closer_appointment_audit scau
        where project_process_step_id = p_project_process_step_id
          and scau.user_id = any (p_users)
        order by distance_from_actual_to_target
        limit 1;
    end if;

    if v_user_id is not null then

        select first_name || ' ' || last_name,
               email
        into v_user_full_name, v_user_email
        from flow."user"
        where id = v_user_id;

        select id
        into v_user_position_id
        from flow.user_position up
        where up.user_id = v_user_id
          and up.primary_flag is true
          and up.position_id in (1, 2, 3);

        select count(1)
        into v_user_already_assigned
        from flow.project_process_step_custom_field_value ppscfv2
        where ppscfv2.project_process_step_id = p_project_process_step_id
          and ppscfv2.custom_field_group_assignment_id = 7
          and int_value is not null;

        if v_user_already_assigned < 1 then


            select uc.default_appointment_length
            into v_default_appointment_length
            from flow.project p
                     inner join flow.company_process cp on cp.id = p.company_process_id
                     inner join flow.user_company uc on uc.company_id = cp.company_id
            where p.id = p_project_id
              and uc.user_id = v_user_id;

            select ppscfv.project_process_step_id, ppscfv.id
            into v_project_process_step_id,v_project_process_step_custom_field_value_id
            from flow.project_process_step_custom_field_value ppscfv
            where ppscfv.project_process_step_id = p_project_process_step_id
              and ppscfv.custom_field_group_assignment_id = 7
            limit 1;
            --         raise notice 'this is v_project_process_step_id %',v_project_process_step_id;
--         raise notice 'this is v_project_process_step_custom_field_value_id %',v_project_process_step_custom_field_value_id;
--         raise notice 'this is v_user_idd %',v_user_id;
            if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
                update flow.project_process_step_custom_field_value
                set int_value      = v_user_position_id,
                    modified_by_id = p_current_user_id,
                    date_modified  = now()
                where id = v_project_process_step_custom_field_value_id;
            else
                INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                          custom_field_group_assignment_id, int_value,
                                                                          date_created, created_by_id, archived)
                VALUES (p_project_process_step_id, 7, v_user_position_id, now(), p_current_user_id, false);
            end if;

            v_project_process_step_id = null;
            v_project_process_step_custom_field_value_id = null;
            select ppscfv.project_process_step_id, ppscfv.id
            into v_project_process_step_id,v_project_process_step_custom_field_value_id
            from flow.project_process_step_custom_field_value ppscfv
            where ppscfv.project_process_step_id = p_project_process_step_id
              and ppscfv.custom_field_group_assignment_id = 5
            limit 1;

            if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
                update flow.project_process_step_custom_field_value
                set timestamp_value = p_appointment_start_time,
                    modified_by_id  = p_current_user_id,
                    date_modified   = now()
                where id = v_project_process_step_custom_field_value_id;
            else
                INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                          custom_field_group_assignment_id,
                                                                          timestamp_value,
                                                                          date_created, created_by_id, archived)
                VALUES (p_project_process_step_id, 5, p_appointment_start_time, now(), p_current_user_id, false);
            end if;

            v_project_process_step_id = null;
            v_project_process_step_custom_field_value_id = null;
            select ppscfv.project_process_step_id, ppscfv.id
            into v_project_process_step_id,v_project_process_step_custom_field_value_id
            from flow.project_process_step_custom_field_value ppscfv
            where ppscfv.project_process_step_id = p_project_process_step_id
              and ppscfv.custom_field_group_assignment_id = 6
            limit 1;

            if v_project_process_step_id is not null and v_project_process_step_custom_field_value_id is not null then
                update flow.project_process_step_custom_field_value
                set timestamp_value = p_appointment_start_time + (v_default_appointment_length || 'minutes')::interval,
                    modified_by_id  = p_current_user_id,
                    date_modified   = now()
                where id = v_project_process_step_custom_field_value_id;
            else
                INSERT INTO flow.project_process_step_custom_field_value (project_process_step_id,
                                                                          custom_field_group_assignment_id,
                                                                          timestamp_value,
                                                                          date_created, created_by_id, archived)
                VALUES (p_project_process_step_id, 6, p_appointment_start_time +
                                                      (v_default_appointment_length || 'minutes')::interval, now(),
                        p_current_user_id, false);
            end if;
            -- raise notice 'user id %',v_user_id;
            -- raise notice 'p_appointment_start_time %',p_appointment_start_time;
            -- raise notice 'v_default_appointment_length %',v_default_appointment_length;
            -- raise notice 'end %',(p_appointment_start_time +
            --                     (v_default_appointment_length || 'minutes')::interval)::timestamp;
            return query select true::boolean,
                                v_user_id::integer,
                                p_appointment_start_time::timestamp,
                                (p_appointment_start_time +
                                 (v_default_appointment_length || 'minutes')::interval)::timestamp,
                                v_user_full_name,
                                v_user_email;
        elsif v_user_already_assigned > 1 and array_length(p_users, 1) > 1 then
            p_users = array_remove(p_users, v_user_id);
            -- raise notice 'i am here';
            return query select *
                         from flow.set_closer_appointment(p_project_id,
                                                          p_current_user_id,
                                                          p_project_process_step_id,
                                                          p_appointment_start_time,
                                                          p_users);
        else
            return query select false::boolean, null::integer, null::timestamp, null::timestamp, null::text, null::text;
        end if;

    else
        return query select false::boolean, null::integer, null::timestamp, null::timestamp, null::text, null::text;
    end if;


END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
