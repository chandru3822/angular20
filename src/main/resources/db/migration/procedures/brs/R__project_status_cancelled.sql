CREATE OR REPLACE FUNCTION brs.project_status_cancelled(p_project_id integer)
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
             inner join flow.project_status_type pst on pst.id = cpst.project_status_type_id
    where p.id = p_project_id
      and pst.project_status_type = 'Cancelled';

    return v_cancelled;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
