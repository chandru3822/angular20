DROP FUNCTION if exists flow.pse_wqt_configuration_change(integer,integer);

CREATE OR REPLACE FUNCTION flow.pse_wqt_configuration_change(p_process_step_event_work_queue_type_id integer,p_created_by_id integer)
RETURNS void as
$$
declare
  v_root_project_status_type_ids integer[];
  v_company_project_status_type_ids integer[];
  v_root_process_step_status_type_ids integer[];
  v_company_process_step_status_type_ids integer[];
  v_process_step_id  integer;
BEGIN

  -- TODO: when keller figures out work queue cycles for events this function needs to be written, backend code is already calling it

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
