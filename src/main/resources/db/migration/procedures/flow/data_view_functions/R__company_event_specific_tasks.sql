CREATE OR REPLACE FUNCTION flow.company_event_specific_tasks(p_company_id integer,
                                                             p_resource_id integer,
                                                             p_project_process_step_event_id integer,
                                                             p_project_id integer,
                                                             p_action text)
  RETURNS void AS

$BODY$
BEGIN
  if p_company_id = 3 and p_action = 'UPDATE_APPOINTMENT_DATA' then
    perform brs.update_appointment_data(p_project_process_step_event_id,p_project_id);
  elsif p_company_id = 3 and p_action = 'UPDATE_OWNER_ON_PROJECT' THEN
    raise notice 'I am here in the company function %',p_project_id;
    update flow.project p
    set user_position_id = p_resource_id,
        date_modified =  now()
    where p.id = p_project_id;
  end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
