-- drop function if exists flow.get_process_step_requirement(bigint);
CREATE OR REPLACE FUNCTION flow.get_process_step_requirement(p_id bigint)
    RETURNS TABLE(
        id integer, process_step_requirement_type_id integer, operator_type_id integer,
        process_requirement_value varchar, custom_field_group_id integer, company_function_id integer,
        requirement_nbr integer, date_created timestamp, date_updated timestamp,
        created_by_id integer, modified_by_id integer, archived boolean, operator_type varchar,
        process_step_requirement_type varchar, parent_id integer, parent_name varchar,
        field_name varchar, company_function text
    ) AS

$BODY$
DECLARE
    v_requirement_type_id integer;
BEGIN
    -- select * from flow.get_process_step_requirement(2)
    select psr2.process_step_requirement_type_id into v_requirement_type_id from flow.process_step_requirement psr2 where psr2.id = p_id;

    case when v_requirement_type_id = 1 then
        return query
            select psr.*,
                   false as archived,
                   ot.operator_type,
                   psrt.process_step_requirement_type,
                   ps.id as parent_id,
                   ps.process_step_name as parent_name,
                   cf.field_name,
                   null::text as company_function
            from flow.process_step_requirement psr
                     inner join flow.custom_field_group cfg on cfg.id = psr.custom_field_group_id
                     inner join flow.custom_field cf on cf.id = cfg.custom_field_id
                     inner join flow.custom_field_group_type cfgt on cfgt.id = cfg.custom_field_group_type_id
                     inner join flow.process_step ps on ps.id = cfgt.process_step_id
                     inner join flow.operator_type ot on ot.id = psr.operator_type_id
                     inner join flow.process_step_requirement_type psrt on psrt.id = psr.process_step_requirement_type_id
            where psr.id = p_id;
      else
        return query
            select psr.*,
                   false as archived,
                   ot.operator_type,
                   psrt.process_step_requirement_type,
                   null::integer as parent_id,
                   null::varchar as parent_name,
                   null::varchar as field_name,
                   'Testing' as company_function
            from flow.process_step_requirement psr
                     inner join flow.operator_type ot on ot.id = psr.operator_type_id
                     inner join flow.process_step_requirement_type psrt on psrt.id = psr.process_step_requirement_type_id
            where psr.id = p_id;
    end case;

END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

