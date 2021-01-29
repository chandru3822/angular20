CREATE OR REPLACE FUNCTION brs.project_status_on_hold(p_project_id integer)
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
    return v_on_hold;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
