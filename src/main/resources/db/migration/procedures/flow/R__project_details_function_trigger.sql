CREATE OR REPLACE FUNCTION flow.project_details()
    RETURNS TRIGGER AS
$$
declare
    v_company_id integer;
BEGIN
    select company_id
        into v_company_id
    from flow.company_process cp
    where process_id = new.company_process_id
    limit 1;

    IF (TG_OP = 'INSERT') THEN
        insert into brs.project_details(project_id,company_id) values (new.id,v_company_id);
    elsif (TG_OP = 'DELETE') THEN
        DELETE FROM brs.project_details where project_id = old.id;
    end if;
    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists project_project_details_trg on flow.project;
CREATE TRIGGER project_project_details_trg
    after INSERT or delete
    ON flow.project
    FOR EACH ROW
EXECUTE PROCEDURE flow.project_details();


CREATE OR REPLACE FUNCTION flow.update_project_details_process_steps()
    RETURNS TRIGGER AS
$body$

declare
    v_field_to_update character varying;
    v_data_type_id    integer;
    v_config_id       integer;
    v_project_id      integer;
    v_sql             character varying;
    v_value           character varying;
BEGIN


    select pdc.id, field_to_update, data_type_id
    into v_config_id,v_field_to_update,v_data_type_id
    from brs.project_details_config pdc
    where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id;

    select pps.project_id
    into v_project_id
    from  flow.project_process_step pps
    where pps.id = new.project_process_step_id
        and pps.main is true;

    if v_config_id is not null and v_data_type_id in (1, 2, 3, 4, 6) and v_project_id is not null then
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

        v_sql = $$update brs.project_details set $$ || v_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || v_project_id;
        --raise notice 'in if %',v_sql;
        execute v_sql;


   end if;

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
    v_field_to_update character varying;
    v_data_type_id    integer;
    v_config_id       integer;
    v_sql             character varying;
    v_value           character varying;
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

        v_sql = $$update brs.project_details set $$ || v_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || new.project_id;
        -- raise notice 'in if %',v_sql;
        execute v_sql;


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
