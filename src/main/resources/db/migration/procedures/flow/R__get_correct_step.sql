CREATE OR REPLACE FUNCTION flow.get_correct_step(
    p_project_process_step_id integer,
    p_process_step_id integer)
    RETURNS TABLE(project_process_step_id integer,process_status_id integer,main boolean,user_position_id integer) AS
$BODY$
DECLARE
BEGIN
    return query
     select a.project_process_step_id,
                    a.process_status_id,
                    a.main,
                    a.user_position_id
             from flow.find_active_process_step_in_downline(p_project_process_step_id,p_process_step_id) as a
             order by main desc,process_status_id,row_number desc limit 1;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;
