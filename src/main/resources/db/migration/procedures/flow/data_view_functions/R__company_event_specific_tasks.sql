drop function if exists flow.company_event_specific_tasks(p_company_id bigint,
                                                          p_resource_id bigint,
                                                          p_project_process_step_event_id bigint,
                                                          p_project_id bigint,
                                                          p_action text,
                                                          p_start_time timestamp);
CREATE OR REPLACE FUNCTION flow.company_event_specific_tasks(p_company_id bigint,
                                                             p_resource_id bigint,
                                                             p_project_process_step_event_id bigint,
                                                             p_project_id bigint,
                                                             p_action text,
                                                             p_start_time timestamp default null)
  RETURNS void AS

$BODY$
BEGIN
  if p_company_id = 3 and p_action = 'UPDATE_APPOINTMENT_DATA' then
    perform brs.update_appointment_data(p_project_process_step_event_id,p_project_id,p_start_time);
  elsif p_company_id = 3 and p_action = 'UPDATE_OWNER_ON_PROJECT' THEN
    update flow.project p
    set user_position_id = p_resource_id,
        date_modified =  now()
    where p.id = p_project_id;
  end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
