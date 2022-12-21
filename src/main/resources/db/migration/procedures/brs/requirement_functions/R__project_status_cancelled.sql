drop function if exists brs.project_status_cancelled(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.project_status_cancelled(p_project_id bigint)
    returns boolean AS
$BODY$
declare
    v_cancelled boolean;
BEGIN
    v_cancelled = false;

    select true
    into v_cancelled
    from flow.project p
             inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
    where p.id = p_project_id
      and cpst.project_status_type_id = 2;

    insert into flow.company_function_log(function_name, db_function_id, parameters)
    values ('Project Status Cancelled', 9, 'p_project_id: ' || p_project_id);

    return v_cancelled;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
