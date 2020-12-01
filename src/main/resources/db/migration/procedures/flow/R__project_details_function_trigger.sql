CREATE OR REPLACE FUNCTION flow.project_details()
    RETURNS TRIGGER AS
$$
declare
    v_company_id             integer;
    v_contact_email          character varying(255);
    v_contact_mobile_phone   character varying(50);
    v_contact_phone          character varying(50);
    v_state_id               integer;
    v_state_abbrev           character varying(2);
    v_contact_name           character varying(150);
    v_owner_user_position_id integer;
    v_owner_user_id          integer;
    v_user_id                integer;
    v_closer_name            varchar;
BEGIN
    select company_id
    into v_company_id
    from flow.company_process cp
    where process_id = new.company_process_id
    limit 1;

    select u.id,first_name||' '||last_name
    into v_user_id,v_closer_name
    from flow.user_position up
    inner join flow.user u on u.id = up.user_id
    where up.id = new.user_position_id;

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

    IF (TG_OP = 'INSERT') THEN
        insert into brs.project_details(project_id, company_id, contact_email,
                                        contact_phone, contact_mobile_phone,
                                        project_street1, project_city, project_postal_code,
                                        project_time_zone, project_state_id, project_state_abbreviation, contact_name,
                                        setter_user_position_id, setter_user_id,closer_user_id,closer_user_position_id,closer_name)
        values (new.id, v_company_id, v_contact_email, v_contact_phone, v_contact_mobile_phone,
                new.street1, new.city, new.postal_code, new.time_zone, v_state_id, v_state_abbrev, v_contact_name,
                v_owner_user_position_id, v_owner_user_id,v_user_id,new.user_position_id,v_closer_name);
    elsif (TG_OP = 'UPDATE') THEN
        update brs.project_details
        set contact_email              = v_contact_email,
            contact_phone              = v_contact_phone,
            contact_mobile_phone       = v_contact_mobile_phone,
            project_street1            = new.street1,
            project_city               = new.city,
            project_postal_code        = new.postal_code,
            project_time_zone          = new.time_zone,
            project_state_id           = v_state_id,
            project_state_abbreviation = v_state_abbrev,
            contact_name               = v_contact_name,
            setter_user_position_id    = v_owner_user_position_id,
            setter_user_id             = v_owner_user_id,
            closer_name                = v_closer_name,
            closer_user_position_id    = new.user_position_id,
            closer_user_id             = v_user_id
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
    v_project_id integer;
    v_sql        character varying;
    v_value      character varying;
    v_record     record;
BEGIN

    select pps.project_id
    into v_project_id
    from flow.project_process_step pps
    where pps.id = new.project_process_step_id
      and pps.main is true;

    for v_record in
        select pdc.id,
               field_to_update,
               data_type_id,
               pdc.second_field_to_update,
               pdc.second_data_type_id,
               cf.list_of_value_id
        from brs.project_details_config pdc
                 left join flow.custom_field_group_assignment cfga on cfga.id = pdc.custom_field_group_assignment_id
                 left join flow.custom_field cf on cf.id = cfga.custom_field_id and cf.list_of_value_id is not null
        where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id
        loop


            if v_record.id is not null and v_record.data_type_id in (1, 2, 3, 4, 5, 6, 7) and
               v_project_id is not null then
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
                    case when new.int_array_value is null then select 'null' into v_value; else select quote_literal(string_agg(lov.name, ', '))
                                                                                                from flow.list_of_value lov
                                                                                                where lov.id = any (new.int_array_value::integer[])
                                                                                                into v_value; end case;
                    v_value = v_value || '::text';
                end if;

                v_sql = $$update brs.project_details set $$ || v_record.field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || v_project_id;
                execute v_sql;

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
                                select quote_literal(first_name ||' '||last_name)
                                into v_value
                                from flow.user u
                                inner join flow.user_position up on up.user_id = u.id
                                where up.id = new.int_value;
                            end case;
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
                        -- raise notice 'value = %',v_value;
                    end if;
                    v_sql = $$update brs.project_details set $$ || v_record.second_field_to_update || $$ = $$ ||
                            v_value || $$
                            where project_id = $$ || v_project_id;
                    execute v_sql;
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
    v_ahj_name               character varying;
BEGIN

    select pdc.id, field_to_update, data_type_id, second_field_to_update
    into v_config_id,v_field_to_update,v_data_type_id,v_second_field_to_update
    from brs.project_details_config pdc
    where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id;

    select ahj.name
    into v_ahj_name
    from flow.custom_field_group_assignment cfga
             inner join flow.custom_field cf on cf.id = cfga.custom_field_id
             inner join brs.ahj ahj on ahj.id = new.int_value
    where cfga.id = new.custom_field_group_assignment_id
      and cf.field_name = 'AHJ'
    limit 1;

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
            case when new.int_value is null then select 'null' into v_value;
                else
                    select quote_literal(name)
                    into v_value
                    from flow.list_of_value
                    where id = new.int_value;
                end case;
            v_sql = $$update brs.project_details set $$ || v_second_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || new.project_id;
            execute v_sql;
        end if;

        if v_ahj_name is not null then
            update brs.project_details
            set ahj_name = v_ahj_name
            where project_id = new.project_id;
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



CREATE OR REPLACE FUNCTION flow.update_project_process_step_custom_value()
    RETURNS TRIGGER AS
$body$

declare
    v_record record;
    v_sql    text;
    v_found  bigint;
    v_count  integer = 0;
BEGIN

    select count(1)
    into v_found
    from flow.project_process_step
    where process_step_id = new.process_step_id
      and project_id = new.project_id
      and id != new.id
      and main is false
      and new.main is true;

    if old.main is false and new.main is true or v_found > 0 then
        v_sql = 'update brs.project_details set ';
        for v_record in
            select  pdc.field_to_update, pdc.second_field_to_update
            from flow.custom_field_group_assignment cfga
                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                     inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                     inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                     inner join flow.data_type dt on dt.id = cdt.data_type_id
                     inner join brs.project_details_config pdc on pdc.custom_field_group_assignment_id = cfga.id
            where cfg.process_step_id = new.process_step_id
              and cf.archived is false
              and cfg.archived is false
              and cfga.archived is false
            loop
                v_count = v_count + 1;
                if v_record.second_field_to_update is not null then
                    if position(v_record.second_field_to_update in v_sql) < 1 then
                        v_sql = v_sql || v_record.second_field_to_update || ' = null ,';
                    end if;
                end if;
                if position(v_record.field_to_update in v_sql) < 1 then
                    v_sql = v_sql || v_record.field_to_update || ' = null,';
                end if;
            end loop;
        v_sql = trim(trailing ',' from v_sql);
        v_sql = v_sql || ' where project_id = ' || new.project_id || ';';
        if v_count > 0 then
            execute v_sql;
        end if;
    end if;

    update flow.project_process_step_custom_field_value
    set id = id
    where project_process_step_id = new.id;
    RETURN NULL;
END
$body$
    LANGUAGE plpgsql;

drop trigger if exists update_project_process_step_custom_value_trg on flow.project_process_step;
CREATE TRIGGER update_project_process_step_custom_value_trg
    after INSERT or update
    ON flow.project_process_step
    FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_process_step_custom_value();
