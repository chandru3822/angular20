drop function if exists flow.company_project_specific_tasks(p_company_id bigint,p_new_company_project_status_type_id bigint,
                                                            p_old_company_project_status_type_id bigint,
                                                            p_project_id bigint);
CREATE OR REPLACE FUNCTION flow.company_project_specific_tasks(p_company_id bigint,p_new_company_project_status_type_id bigint,
                                                       p_old_company_project_status_type_id bigint,
                                                       p_project_id bigint)

RETURNS void AS

$BODY$
DECLARE
  v_new_project_status_type_id bigint;
  v_old_project_status_type_id bigint;
  v_cancelled_date             timestamp;
  v_on_hold_date               timestamp;
  v_off_hold_date              timestamp;
BEGIN
  if p_company_id = 3 then
    select pst.id
    into v_new_project_status_type_id
    from flow.project_status_type pst
           inner join flow.company_project_status_type cpst on pst.id = cpst.project_status_type_id
    where cpst.id = p_new_company_project_status_type_id;

    select pst.id
    into v_old_project_status_type_id
    from flow.project_status_type pst
           inner join flow.company_project_status_type cpst on pst.id = cpst.project_status_type_id
    where cpst.id = p_old_company_project_status_type_id;

    select on_hold_date, off_hold_date
    into v_on_hold_date,v_off_hold_date
    from brs.project_details
    where project_id = p_project_id;

    if v_new_project_status_type_id = 1 and v_old_project_status_type_id = 2 then
      v_cancelled_date = null;
      update brs.project_details
      set cancelled_date = v_cancelled_date
      where project_id = p_project_id;
      if v_on_hold_date is not null and v_off_hold_date is null then
        v_off_hold_date = now();
        update brs.project_details
        set off_hold_date = v_off_hold_date
        where project_id = p_project_id;
      end if;

    elsif v_new_project_status_type_id = 1 and v_old_project_status_type_id = 3 then
      v_off_hold_date = now();
      update brs.project_details
      set off_hold_date = v_off_hold_date
      where project_id = p_project_id;
    elsif v_new_project_status_type_id = 2 and v_old_project_status_type_id = 1 then
      v_cancelled_date = now();
      update brs.project_details
      set cancelled_date = v_cancelled_date
      where project_id = p_project_id;

    elsif v_new_project_status_type_id = 2 and v_old_project_status_type_id = 3 then
      v_cancelled_date = now();
      update brs.project_details
      set cancelled_date = v_cancelled_date
      where project_id = p_project_id;

    elsif v_new_project_status_type_id = 3 and v_old_project_status_type_id = 1 then
      v_on_hold_date = now();
      v_off_hold_date = null;
      update brs.project_details
      set on_hold_date  = v_on_hold_date,
          off_hold_date = v_off_hold_date
      where project_id = p_project_id;
    elsif v_new_project_status_type_id = 3 and v_old_project_status_type_id = 2 then
      v_on_hold_date = now();
      v_off_hold_date = null;
      v_cancelled_date = null;
      update brs.project_details
      set on_hold_date   = v_on_hold_date,
          off_hold_date  = v_off_hold_date,
          cancelled_date = v_cancelled_date
      where project_id = p_project_id;
    end if;
  end if;

END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
