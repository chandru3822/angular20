CREATE OR REPLACE FUNCTION flow.project_details_from_contact()
    RETURNS TRIGGER AS
$$
declare
    v_owner_user_position_id     integer;
    v_owner_user_id              integer;
    v_project_ids                 integer[];
BEGIN
    select  owner_user_position_id, up.user_id
    into v_owner_user_position_id,v_owner_user_id
    from flow.contact c
             left join flow.user_position up on up.id = c.owner_user_position_id
    where c.id = new.id;


    select array_agg(id)
    into v_project_ids
    from flow.project
    where contact_id = new.id;

        update brs.project_details
        set
            setter_user_position_id        = v_owner_user_position_id,
            setter_user_id                 = v_owner_user_id
        where project_id = any(v_project_ids);

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists project_project_details_for_contact_trg on flow.contact;
CREATE TRIGGER project_project_details_for_contact_trg
    after update
    ON flow.contact
    FOR EACH ROW
EXECUTE PROCEDURE flow.project_details_from_contact();




CREATE OR REPLACE FUNCTION flow.project_details()
    RETURNS TRIGGER AS
$$
declare
    v_company_id                 integer;
    v_contact_email              character varying(255);
    v_contact_mobile_phone       character varying(50);
    v_contact_phone              character varying(50);
    v_state_id                   integer;
    v_state_abbrev               character varying(2);
    v_contact_name               character varying(150);
    v_owner_user_position_id     integer;
    v_owner_user_id              integer;
    v_user_id                    integer;
    v_closer_name                varchar;
    v_pd_closer_user_position_id integer;
    v_project_creator            varchar;
    v_new_project_status_type_id integer;
    v_old_project_status_type_id integer;
    v_cancelled_date             timestamp;
    v_on_hold_date               timestamp;
    v_off_hold_date              timestamp;
    v_company_project_status     character varying(100);
BEGIN
    select company_id
    into v_company_id
    from flow.company_process cp
    where process_id = new.company_process_id
    limit 1;

    select u3.first_name || ' ' || u3.last_name
    into v_project_creator
    from flow."user" u3
    where u3.id = new.created_by_id;

    select project_status_type
    into v_company_project_status
    from flow.company_project_status_type
    where id = new.company_project_status_type_id;

    if new.user_position_id is not null then
        select u.id, first_name || ' ' || last_name
        into v_user_id,v_closer_name
        from flow.user_position up
                 inner join flow.user u on u.id = up.user_id
        where up.id = new.user_position_id;
    else
        select pd.closer_user_id, pd.closer_name, pd.closer_user_position_id
        into v_user_id,v_closer_name,v_pd_closer_user_position_id
        from brs.project_details pd
        where pd.project_id = new.id;
    end if;

    select email, phone, mobile, first_name || ' ' || last_name, owner_user_position_id, up.user_id
    into v_contact_email,v_contact_phone,v_contact_mobile_phone,v_contact_name,v_owner_user_position_id,v_owner_user_id
    from flow.contact c
             left join flow.user_position up on up.id = c.owner_user_position_id
    where c.id = new.contact_id;

    select s.id, s.abbreviation
    into v_state_id,v_state_abbrev
    from flow.company_state cs
             inner join flow.state s on cs.state_id = s.id
    where cs.id = new.company_state_id;

    select pst.id
    into v_new_project_status_type_id
    from flow.project_status_type pst
             inner join flow.company_project_status_type cpst on pst.id = cpst.project_status_type_id
    where cpst.id = new.company_project_status_type_id;

    select pst.id
    into v_old_project_status_type_id
    from flow.project_status_type pst
             inner join flow.company_project_status_type cpst on pst.id = cpst.project_status_type_id
    where cpst.id = old.company_project_status_type_id;

    select on_hold_date, off_hold_date
    into v_on_hold_date,v_off_hold_date
    from brs.project_details
    where project_id = new.id;

    if v_new_project_status_type_id = 1 and v_old_project_status_type_id = 2 then
        v_cancelled_date = null;
        update brs.project_details
        set cancelled_date = v_cancelled_date
        where project_id = new.id;
        if v_on_hold_date is not null and v_off_hold_date is null then
            v_off_hold_date = now();
            update brs.project_details
            set off_hold_date = v_off_hold_date
            where project_id = new.id;
        end if;

    elsif v_new_project_status_type_id = 1 and v_old_project_status_type_id = 3 then
        v_off_hold_date = now();
        update brs.project_details
        set off_hold_date = v_off_hold_date
        where project_id = new.id;
    elsif v_new_project_status_type_id = 2 and v_old_project_status_type_id = 1 then
        v_cancelled_date = now();
        update brs.project_details
        set cancelled_date = v_cancelled_date
        where project_id = new.id;
        --         insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id)
--         select 99999999,
--                concat('Project ID ', p.id, ' for ', p.project_name, ' at ', p.street1, ', ', p.city, ', ', s.abbreviation, ' has been canceled.'),
--                (SELECT md5(random()::text || clock_timestamp()::text)::uuid),
--                (select u.phone_number from flow.user_position up
--                                                inner join flow."user" u on up.user_id = u.id
--                 where up.id = p.user_position_id),
--                now(), 1
--         from flow.project p
--                  inner join flow.company_state cs on cs.id = p.company_state_id
--                  inner join flow.state s on cs.state_id = s.id
--         where p.id = new.id;
    elsif v_new_project_status_type_id = 2 and v_old_project_status_type_id = 3 then
        v_cancelled_date = now();
        update brs.project_details
        set cancelled_date = v_cancelled_date
        where project_id = new.id;
        --         insert into flow.sms_queue(user_id, message, message_group, to_phone, created, recipient_type_id)
--         select 99999999,
--                concat('Project ID ', p.id, ' for ', p.project_name, ' at ', p.street1, ', ', p.city, ', ', s.abbreviation, ' has been canceled.'),
--                (SELECT md5(random()::text || clock_timestamp()::text)::uuid),
--                (select u.phone_number from flow.user_position up
--                                                inner join flow."user" u on up.user_id = u.id
--                 where up.id = p.user_position_id),
--                now(), 1
--         from flow.project p
--                  inner join flow.company_state cs on cs.id = p.company_state_id
--                  inner join flow.state s on cs.state_id = s.id
--         where p.id = new.id;
    elsif v_new_project_status_type_id = 3 and v_old_project_status_type_id = 1 then
        v_on_hold_date = now();
        v_off_hold_date = null;
        update brs.project_details
        set on_hold_date  = v_on_hold_date,
            off_hold_date = v_off_hold_date
        where project_id = new.id;
    elsif v_new_project_status_type_id = 3 and v_old_project_status_type_id = 2 then
        v_on_hold_date = now();
        v_off_hold_date = null;
        v_cancelled_date = null;
        update brs.project_details
        set on_hold_date   = v_on_hold_date,
            off_hold_date  = v_off_hold_date,
            cancelled_date = v_cancelled_date
        where project_id = new.id;
    end if;

    IF (TG_OP = 'INSERT') THEN
        insert into brs.project_details(project_id, company_id, contact_email,
                                        contact_phone, contact_mobile_phone,
                                        project_street1, project_city, project_postal_code,
                                        project_time_zone, project_state_id, project_state_abbreviation, contact_name,
                                        setter_user_position_id, setter_user_id, closer_user_id,
                                        closer_user_position_id, closer_name,
                                        project_creator, contact_id, project_created_date,
                                        company_project_status_type_id, company_project_status_type)
        values (new.id, v_company_id, v_contact_email, v_contact_phone, v_contact_mobile_phone,
                new.street1, new.city, new.postal_code, new.time_zone, v_state_id, v_state_abbrev, v_contact_name,
                v_owner_user_position_id, v_owner_user_id, v_user_id,
                coalesce(new.user_position_id, v_pd_closer_user_position_id), v_closer_name,
                v_project_creator, new.contact_id, new.date_created,
                new.company_project_status_type_id, v_company_project_status);
    elsif (TG_OP = 'UPDATE') THEN
        update brs.project_details
        set contact_email                  = v_contact_email,
            contact_phone                  = v_contact_phone,
            contact_mobile_phone           = v_contact_mobile_phone,
            project_street1                = new.street1,
            project_city                   = new.city,
            project_postal_code            = new.postal_code,
            project_time_zone              = new.time_zone,
            project_state_id               = v_state_id,
            project_state_abbreviation     = v_state_abbrev,
            contact_name                   = v_contact_name,
            setter_user_position_id        = v_owner_user_position_id,
            setter_user_id                 = v_owner_user_id,
            closer_name                    = v_closer_name,
            closer_user_position_id        = coalesce(new.user_position_id, v_pd_closer_user_position_id),
            closer_user_id                 = v_user_id,
            project_creator                = v_project_creator,
            contact_id                     = new.contact_id,
            project_created_date           = new.date_created,
            company_project_status_type_id = new.company_project_status_type_id,
            company_project_status_type    = v_company_project_status
        where project_id = new.id;

    elsif (TG_OP = 'DELETE') THEN
        DELETE FROM brs.project_details where project_id = old.id;
    end if;
    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists project_project_details_trg on flow.project;
CREATE TRIGGER project_project_details_trg
    after INSERT or delete or update
    ON flow.project
    FOR EACH ROW
EXECUTE PROCEDURE flow.project_details();


CREATE OR REPLACE FUNCTION flow.update_project_details_process_steps()
    RETURNS TRIGGER AS
$body$

declare
    v_project_id                     integer;
    v_sql                            character varying;
    v_value                          character varying;
    v_record                         record;
    v_parent_project_process_step_id integer;
    v_timestamp_value                timestamp;
    v_project_id1                    integer;
    v_field_name                     varchar;
    v_parent_custom_field_id         integer;
    v_project_id2                    integer;
BEGIN

    select pps.project_id
    into v_project_id
    from flow.project_process_step pps
    where pps.id = new.project_process_step_id
      and pps.main is true;

    select pps.project_id
    into v_project_id1
    from flow.project_process_step pps
             inner join flow.process_step ps on pps.process_step_id = ps.id
    where pps.id = new.project_process_step_id;


    select cf.field_name, cf.parent_custom_field_id
    into v_field_name,v_parent_custom_field_id
    from flow.custom_field_group_assignment cfga
             inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and cfg.archived is false
             inner join flow.custom_field cf on cfga.custom_field_id = cf.id and cf.archived is false
    where cfga.id = new.custom_field_group_assignment_id
      and cfga.archived is false;


    if v_parent_custom_field_id = 10541 then
        select pps2.parent_project_process_step_id
        into v_parent_project_process_step_id
        from flow.project_process_step pps2
        where pps2.id = new.project_process_step_id;

        if v_parent_project_process_step_id is not null then

            select timestamp_value
            into v_timestamp_value
            from flow.project_process_step pps3
                     inner join flow.project_process_step_custom_field_value ppscfv
                                on pps3.id = ppscfv.project_process_step_id and
                                   ppscfv.custom_field_group_assignment_id = 5
            where pps3.id = v_parent_project_process_step_id
              and pps3.process_step_id = 1;
        else
            select min(timestamp_value)
            into v_timestamp_value
            from flow.project_process_step pps4
                     inner join flow.project_process_step_custom_field_value ppscfv1
                                on pps4.id = ppscfv1.project_process_step_id and
                                   ppscfv1.custom_field_group_assignment_id = 5
            where pps4.project_id = v_project_id1
              and pps4.process_step_id = 1
            limit 1;

        end if;

        if new.int_value is not null then
            update brs.project_details
            set first_appointment_id = new.int_value,
                first_appointment_pps_id = new.project_process_step_id
            where project_id = v_project_id1
              and (first_appointment_id is null or (first_appointment_pps_id is not null and first_appointment_pps_id = new.project_process_step_id));
        end if;

        if new.int_value in (2, 1139, 1140) then

            update brs.project_details
            set setter_milestone_pay = coalesce(v_timestamp_value, now()),
                setter_milestone_pay_ppscfv_id = new.id
            where project_id = v_project_id1
             and (setter_milestone_pay is null or (setter_milestone_pay_ppscfv_id is not null and setter_milestone_pay_ppscfv_id = new.id));

            update brs.project_details
            set first_appointment_pitched    = coalesce(v_timestamp_value, now()),
                first_appointment_pitched_id = new.int_value,
                first_appointment_pitched_ppscfv_id = new.id
            where project_id = v_project_id1
              and (first_appointment_pitched is null or (first_appointment_pitched_ppscfv_id is not null and first_appointment_pitched_ppscfv_id = new.id));
        elsif new.int_value in (3) then
            update brs.project_details
            set setter_milestone_pay = coalesce(v_timestamp_value, now()),
                setter_milestone_pay_ppscfv_id = new.id
            where project_id = v_project_id1
              and (setter_milestone_pay is null or (setter_milestone_pay_ppscfv_id is not null and setter_milestone_pay_ppscfv_id = new.id));

            update brs.project_details
            set first_appointment_missed    = coalesce(v_timestamp_value, now()),
                first_appointment_missed_id = new.int_value,
                first_appointment_missed_ppscfv_id = new.id
            where project_id = v_project_id1
              and (first_appointment_missed is null or (first_appointment_missed_ppscfv_id is not null and first_appointment_missed_ppscfv_id = new.id));
        elseif new.int_value is not null and
               new.int_value not in (2, 3, 1139, 1140) then
            update brs.project_details
            set first_appointment_not_pitched_or_missed    =coalesce(v_timestamp_value, now()),
                first_appointment_not_pitched_or_missed_id = new.int_value,
                first_appointment_not_pitched_or_missed_ppscfv_id = new.id
            where project_id = v_project_id1
              and (first_appointment_not_pitched_or_missed is null or (first_appointment_not_pitched_or_missed_ppscfv_id is not null and first_appointment_not_pitched_or_missed_ppscfv_id = new.id));
        end if;
    elsif v_parent_custom_field_id = 9958 and
          new.timestamp_value is not null then
        update brs.project_details
        set first_appointment        = new.timestamp_value,
            first_appointment_pps_id = new.project_process_step_id
        where project_id = v_project_id1
          and (first_appointment is null or (first_appointment_pps_id is not null and first_appointment_pps_id = new.project_process_step_id));
    end if;


    for v_record in
        select pdc.id,
               field_to_update,
               data_type_id,
               pdc.second_field_to_update,
               pdc.second_data_type_id,
               cf.list_of_value_id,
               pdc.update_first_value_only,
               pdc.update_first_value_only_id
        from brs.project_details_config pdc
                 inner join flow.custom_field_group_assignment cfga on cfga.id = pdc.custom_field_group_assignment_id
                 inner join flow.custom_field cf on cf.id = cfga.custom_field_id
        where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id
        loop

            if v_record.id is not null and v_record.data_type_id in (1, 2, 3, 4, 5, 6, 7) and
               (v_project_id is not null or v_record.update_first_value_only is true) then
                if v_record.data_type_id = 1 then
                    case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
                    v_value = v_value || '::date';
                elsif v_record.data_type_id = 2 then
                    case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
                    v_value = v_value || '::timestamp';
                elsif v_record.data_type_id = 4 then
                    case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
                    v_value = v_value || '::numeric';
                elsif v_record.data_type_id = 5 then
                    case when new.text_value is null then select 'null' into v_value; else select quote_literal(new.text_value) into v_value; end case;
                    v_value = v_value || '::text';
                elsif v_record.data_type_id = 6 then
                    case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
                    v_value = v_value || '::integer';
                elsif v_record.data_type_id = 3 then
                    case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
                    v_value = v_value || '::boolean';
                elsif v_record.data_type_id = 7 then
                    case when new.int_array_value is null or new.int_array_value = '{}' then select 'null' into v_value; else select quote_literal(string_agg(lov.name, ', '))
                                                                                                                              from flow.list_of_value lov
                                                                                                                              where lov.id = any (new.int_array_value::integer[])
                                                                                                                              into v_value; end case;
                    v_value = v_value || '::text';
                end if;
                v_project_id2 = coalesce(v_project_id, v_project_id1);
                case when v_record.update_first_value_only is false then
                  v_sql = $$update brs.project_details set $$ || v_record.field_to_update || $$ = $$ || v_value || $$
                          where project_id = $$ || v_project_id2;
                 -- raise notice 'what is the sql %',v_sql;
                else
                v_sql = $$update brs.project_details set $$ || v_record.field_to_update || $$ = $$ || v_value || $$,$$
                          ||v_record.update_first_value_only_id||$$ = $$|| new.id|| $$
                          where project_id = $$ || v_project_id2 || $$ and
                          ($$ || v_record.field_to_update ||
                        $$ is null or ( $$ || v_record.update_first_value_only_id || $$ is not null and  $$|| v_record.update_first_value_only_id || $$ = $$ || new.id || $$))$$;
               -- raise notice 'what is the sql %',v_sql;
                end case;

                begin
                    execute v_sql;
                exception
                    when others then
                        insert into flow.trigger_error(project_process_step_custom_value_id, error)
                        values (new.id, SQLERRM);
                end;


                if v_record.second_field_to_update is not null then
                    if v_record.field_to_update in
                       ('proposal_number_id', 'proposal_number_id_closer_appointment', 'proposal_number_id_booking',
                        'proposal_number_id_final_design') then
                        case when new.int_value is null then select 'null' into v_value;
                            else
                                select quote_literal(proposal_nbr)
                                into v_value
                                from brs.proposal_log_history
                                where id = new.int_value;
                            end case;
                    elsif v_record.field_to_update = 'closer_user_position_id' and
                          v_record.second_field_to_update = 'closer_user_id' then
                        case when new.int_value is null then select 'null' into v_value;
                            else
                                select quote_literal(user_id)
                                into v_value
                                from flow.user_position
                                where id = new.int_value;
                            end case;
                    elsif v_record.field_to_update = 'closer_user_position_id' and
                          v_record.second_field_to_update = 'closer_name' then
                        case when new.int_value is null then select 'null' into v_value;
                            else
                                select quote_literal(first_name || ' ' || last_name)
                                into v_value
                                from flow.user u
                                         inner join flow.user_position up on up.user_id = u.id
                                where up.id = new.int_value;
                            end case;
                    elsif v_record.field_to_update in ('installation_resource', 'permit_pack_submittal_resource',
                                                       'in_house_mpu_permit_submittal_resource',
                                                       'permit_pickup_resource', 'ac_compressor_relocation_resource',
                                                       'as_built_permit_pickup_resource',
                                                       'as_built_permit_submission_resource',
                                                       'in_house_mpu_permit_pickup_resource', 'in_house_mpu_resource',
                                                       'installation_closeout_resource',
                                                       'non_standard_installation_resource',
                                                       'outsource_mpu_resource', 'reroof_resource',
                                                       'structural_upgrade_resource',
                                                       'tree_trimming_resource', 'trenching_resource',
                                                       'work_order_resource') then

                        case when new.int_value is null then select 'null' into v_value;
                            else
                                select quote_literal(org_name)
                                into v_value
                                from flow.org o
                                where o.id = new.int_value;
                            end case;
                        -- raise notice 'value&&&&&&&&&&&& = %',v_value;
                    elsif v_record.list_of_value_id is not null then
                        case when new.int_value is null then select 'null' into v_value;
                            else
                                select quote_literal(name)
                                into v_value
                                from flow.list_of_value
                                where id = new.int_value;
                            end case;
                    elsif v_record.data_type_id = 2 and v_record.second_data_type_id = 1 then
                        case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
                        v_value = '(' || v_value || '::timestamp at time zone ' || quote_literal('UTC') ||
                                  ' at time zone ' || quote_literal('US/Mountain') || ')::date';

                    end if;
                    case when v_record.update_first_value_only is false then
                      --raise notice 'am I here*********';
                      v_sql = $$update brs.project_details set $$ || v_record.second_field_to_update || $$ = $$ ||
                              v_value || $$
                            where project_id = $$ || v_project_id2;
                      --raise notice 'what is the sql in the second field %',v_sql;
                    else
                    v_sql = $$update brs.project_details set $$ || v_record.second_field_to_update || $$ = $$ ||
                            v_value || $$,$$
                              ||v_record.update_first_value_only_id||$$ = $$|| new.id|| $$
                            where project_id = $$ || v_project_id2 || $$ and ($$ ||
                            v_record.second_field_to_update || $$ is null or ( $$ || v_record.update_first_value_only_id || $$ is not null and $$|| v_record.update_first_value_only_id || $$ = $$ || new.id || $$))$$;
                    --raise notice 'what is the sql in the second field %',v_sql;
                    end case;

                    begin
                        execute v_sql;
                    exception
                        when others then
                            insert into flow.trigger_error(project_process_step_custom_value_id, error)
                            values (new.id, SQLERRM);
                    end;
                end if;
            end if;
        end loop;
    RETURN NULL;
END
$body$
    LANGUAGE plpgsql;

drop trigger if exists update_project_details_trg on flow.project_process_step_custom_field_value;
CREATE TRIGGER update_project_details_trg
    after INSERT or update
    ON flow.project_process_step_custom_field_value
    FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_details_process_steps();

CREATE OR REPLACE FUNCTION flow.pps_update_project_details()
    RETURNS TRIGGER AS
$body$
declare
    v_parent_process_step_id integer;
BEGIN

    select ps.parent_process_step_id
    into v_parent_process_step_id
    from flow.process_step ps
    where new.process_step_id = ps.id;

    if v_parent_process_step_id = 3166 and new.process_step_complete_date is not null then
        update brs.project_details
        set complete_date_booking = new.process_step_complete_date
        where project_id = new.project_id
          and complete_date_booking is null;
    elsif v_parent_process_step_id = 3241 and new.process_step_complete_date is not null then
        update brs.project_details
        set complete_date_final_design_completion = new.process_step_complete_date
        where project_id = new.project_id
          and complete_date_final_design_completion is null;
    end if;

    RETURN NULL;
END
$body$
    LANGUAGE plpgsql;

drop trigger if exists pps_update_project_details_trg on flow.project_process_step;
CREATE TRIGGER pps_update_project_details_trg
    after INSERT or update
    ON flow.project_process_step
    FOR EACH ROW
EXECUTE PROCEDURE flow.pps_update_project_details();


CREATE OR REPLACE FUNCTION flow.update_project_details_project()
    RETURNS TRIGGER AS
$body$

declare
    v_field_to_update        character varying;
    v_data_type_id           integer;
    v_config_id              integer;
    v_sql                    character varying;
    v_value                  character varying;
    v_second_field_to_update character varying;
BEGIN

    select pdc.id, field_to_update, data_type_id, second_field_to_update
    into v_config_id,v_field_to_update,v_data_type_id,v_second_field_to_update
    from brs.project_details_config pdc
    where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id;


    if v_config_id is not null and v_data_type_id in (1, 2, 3, 4, 6, 5) then
        if v_data_type_id = 1 then
            case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
            v_value = v_value || '::date';
        elsif v_data_type_id = 2 then
            case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
            v_value = v_value || '::timestamp';
        elsif v_data_type_id = 4 then
            case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
            v_value = v_value || '::numeric';
        elsif v_data_type_id = 6 then
            case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
            v_value = v_value || '::integer';
        elsif v_data_type_id = 5 then
            case when new.text_value is null then select 'null' into v_value; else select quote_literal(new.text_value) into v_value; end case;
            v_value = v_value || '::text';
        elsif v_data_type_id = 3 then
            case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
            v_value = v_value || '::boolean';
        end if;

        v_sql = $$update brs.project_details set $$ || v_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || new.project_id;
        -- raise notice 'in if %',v_sql;
        execute v_sql;

        if v_second_field_to_update is not null then
            if v_field_to_update = 'ahj' and new.int_value is not null then
                select quote_literal(ahj.name)
                into v_value
                from brs.ahj ahj
                where ahj.id = new.int_value
                limit 1;
            elsif v_field_to_update = 'utility_company' and new.int_value is not null then
                select quote_literal(au.name)
                into v_value
                from brs.ahj_utility au
                where au.id = new.int_value
                limit 1;
            elsif v_field_to_update = 'sales_dev_representative_id' or v_field_to_update = 'inside_sales_consultant_id' then
                case when new.int_value is null then select 'null' into v_value;
                    else
                        select quote_literal(coalesce(u.first_name, ' ') || ' ' || coalesce(u.last_name, ' '))
                        into v_value
                        from flow.user_position up
                                 inner join flow.user u on up.user_id = u.id
                        where up.id = new.int_value;
                    end case;
            else
                case when new.int_value is null then select 'null' into v_value;
                    else
                        select quote_literal(name)
                        into v_value
                        from flow.list_of_value
                        where id = new.int_value;
                    end case;
            end if;
            v_sql = $$update brs.project_details set $$ || v_second_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || new.project_id;
            execute v_sql;
        end if;
    end if;

    RETURN NULL;
END
$body$
    LANGUAGE plpgsql;

drop trigger if exists update_project_details_project_trg on flow.project_custom_field_value;
CREATE TRIGGER update_project_details_project_trg
    after INSERT or update
    ON flow.project_custom_field_value
    FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_details_project();


CREATE OR REPLACE FUNCTION flow.update_contact_details_project_details()
    RETURNS TRIGGER AS
$body$

declare
    v_field_to_update character varying;
    v_data_type_id    integer;
    v_config_id       integer;
    v_sql             character varying;
    v_value           character varying;
    v_record          record;
    v_count           bigint;
BEGIN


    select pdc.id, field_to_update, data_type_id
    into v_config_id,v_field_to_update,v_data_type_id
    from brs.project_details_config pdc
    where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id;


    if v_config_id is not null and v_data_type_id in (1, 2, 3, 4, 6) then
        if v_data_type_id = 1 then
            case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
            v_value = v_value || '::date';
        elsif v_data_type_id = 2 then
            case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
            v_value = v_value || '::timestamp';
        elsif v_data_type_id = 4 then
            case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
            v_value = v_value || '::numeric';
        elsif v_data_type_id = 6 then
            case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
            v_value = v_value || '::integer';
        elsif v_data_type_id = 3 then
            case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
            v_value = v_value || '::boolean';
        end if;

        for v_record in select id
                        from flow.project
                        where contact_id = new.contact_id
            loop
                v_sql = $$update brs.project_details set $$ || v_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || v_record.id;
                -- raise notice 'in if %',v_sql;
                execute v_sql;
            end loop;


    end if;

    if (TG_OP = 'UPDATE') THEN

      select count(1)
      into v_count
      from flow.user_position up
      inner join flow.white_listed_position wlp on wlp.position_id = up.position_id and wlp.archived is false
      where up.user_id = new.modified_by_id and
            up.end_date is null and wlp.custom_field_group_assignment_id = 395;
      if new.custom_field_group_assignment_id = 395 and old.int_value != new.int_value and v_count < 1 then
        raise exception 'You do not have rights to update the Lead Source for this Contact.';
      end if;
    end if;

    RETURN NULL;
END
$body$
    LANGUAGE plpgsql;

drop trigger if exists update_contact_details_project_details_trg on flow.contact_custom_field_value;
CREATE TRIGGER update_contact_details_project_details_trg
    after INSERT or update
    ON flow.contact_custom_field_value
    FOR EACH ROW
EXECUTE PROCEDURE flow.update_contact_details_project_details();



-- CREATE OR REPLACE FUNCTION flow.update_project_process_step_custom_value()
--     RETURNS TRIGGER AS
-- $body$
--
-- declare
--     v_record record;
--     v_sql    text;
--     v_found  bigint;
--     v_count  integer = 0;
-- BEGIN
--
--     select count(1)
--     into v_found
--     from flow.project_process_step
--     where process_step_id = new.process_step_id
--       and project_id = new.project_id
--       and id != new.id
--       and main is false
--       and new.main is true;
--
--     if old.main is false and new.main is true or v_found > 0 then
--         v_sql = 'update brs.project_details set ';
--         for v_record in
--             select pdc.field_to_update, pdc.second_field_to_update
--             from flow.custom_field_group_assignment cfga
--                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
--                      inner join flow.custom_field cf on cf.id = cfga.custom_field_id
--                      inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
--                      inner join flow.data_type dt on dt.id = cdt.data_type_id
--                      inner join brs.project_details_config pdc on pdc.custom_field_group_assignment_id = cfga.id
--             where cfg.process_step_id = new.process_step_id
--               and cf.archived is false
--               and cfg.archived is false
--               and cfga.archived is false
--               and cf.parent_custom_field_id not in (10283, 10248,
--                                                 10057, 10118,
--                                                 10243, 10242)
--             loop
--                 v_count = v_count + 1;
--                 if v_record.second_field_to_update is not null then
--                     if not v_record.second_field_to_update = any (string_to_array(v_sql, ' ')) then
--                         v_sql = v_sql || v_record.second_field_to_update || ' = null , ';
--                     end if;
--                 end if;
--                 if not v_record.field_to_update = any (string_to_array(v_sql, ' ')) then
--                     v_sql = v_sql || v_record.field_to_update || ' = null , ';
--                 end if;
--             end loop;
--         v_sql = trim(trailing ' ,' from v_sql);
--         v_sql = v_sql || ' where project_id = ' || new.project_id || ';';
--         if v_count > 0 then
--             -- raise notice 'v_sql%',v_sql;
--             execute v_sql;
--         end if;
--     end if;
--
--     update flow.project_process_step_custom_field_value
--     set id = id
--     where project_process_step_id = new.id;
--     RETURN NULL;
-- END
-- $body$
--     LANGUAGE plpgsql;
--
-- drop trigger if exists update_project_process_step_custom_value_trg on flow.project_process_step;
-- CREATE TRIGGER update_project_process_step_custom_value_trg
--     after INSERT or update
--     ON flow.project_process_step
--     FOR EACH ROW
-- EXECUTE PROCEDURE flow.update_project_process_step_custom_value();
