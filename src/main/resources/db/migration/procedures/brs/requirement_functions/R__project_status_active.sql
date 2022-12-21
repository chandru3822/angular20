drop function if exists brs.project_status_active(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.project_status_active(p_project_id bigint)
    returns boolean AS
$BODY$
declare
    v_active boolean;
BEGIN
    v_active = false;

    select true
    into v_active
    from flow.project p
             inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
    where p.id = p_project_id
      and cpst.project_status_type_id = 1;

    insert into flow.company_function_log(function_name, db_function_id, parameters)
    values ('Project status Active', 8, 'p_project_id: ' || p_project_id);

    return v_active;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
