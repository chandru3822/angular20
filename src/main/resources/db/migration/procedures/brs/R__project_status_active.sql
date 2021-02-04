CREATE OR REPLACE FUNCTION brs.project_status_active(p_project_id integer)
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

    return v_active;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
