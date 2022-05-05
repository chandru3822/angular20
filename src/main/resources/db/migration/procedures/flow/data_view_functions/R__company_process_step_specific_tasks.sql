CREATE OR REPLACE FUNCTION flow.company_process_step_specific_tasks(p_process_step_id integer,
                                                                    p_process_step_complete_date timestamp,
                                                                    p_project_id integer)
  RETURNS void AS

$BODY$
BEGIN


  if p_process_step_id = 4  then
    update brs.project_details
    set complete_date_booking = p_process_step_complete_date
    where project_id = p_project_id
      and complete_date_booking is null;
  elsif p_process_step_id = 175 then
    update brs.project_details
    set complete_date_final_design_completion = p_process_step_complete_date
    where project_id = p_project_id
      and complete_date_final_design_completion is null;
  end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
