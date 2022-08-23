drop function if exists flow.company_custom_field_event_specific_tasks(p_company_id bigint,
                                                                       p_project_process_step_event_id bigint,
                                                                       p_project_id bigint);
CREATE OR REPLACE FUNCTION flow.company_custom_field_event_specific_tasks(p_company_id bigint,
                                                             p_project_process_step_event_id bigint,
                                                             p_project_id bigint)
  RETURNS void AS

$BODY$
BEGIN
  if p_company_id = 3 then
    perform brs.update_appointment_data(p_project_process_step_event_id, p_project_id);
  end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
