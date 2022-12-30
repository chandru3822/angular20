drop function if exists brs.project_status_on_hold(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.project_status_on_hold(p_project_id bigint)
    returns boolean AS
$BODY$
declare
    v_on_hold boolean;
BEGIN
    v_on_hold = false;

    select true
    into v_on_hold
    from flow.project p
             inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
    where p.id = p_project_id
      and cpst.project_status_type_id = 3;
    if v_on_hold is null then
        v_on_hold = false;
    end if;

    insert into flow.company_function_log(function_name, db_function_id, parameters)
    values ('Project Status On Hold', 10, 'p_project_id: ' || p_project_id);

    return v_on_hold;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
