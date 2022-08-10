--drop function brs.closer_active(integer)
CREATE OR REPLACE FUNCTION brs.closer_active(p_project_id integer)
    returns boolean AS
$BODY$
declare
    v_closer_inactive boolean;
BEGIN
    v_closer_inactive = false;

    select true into v_closer_inactive
    from brs.project_details pd
           inner join flow.company_user_status cus on pd.closer_user_id = cus.user_id
           inner join flow.user_status_type ust on cus.user_status_type_id = ust.id
    where pd.project_id = p_project_id
      and ust.has_access is true;

    return case when v_closer_inactive is null then false else v_closer_inactive end;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
