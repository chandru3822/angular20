-- drop function if exists flow.duplicate_event_action(int, int);
CREATE OR REPLACE FUNCTION flow.duplicate_event_action(p_process_step_event_action_id int, p_current_user_id int, p_company_id int)
    returns int AS
$BODY$
declare
    v_new_event_action_id int;
BEGIN
  -- the company_id comes from the login token, so it ensures the user has access to the company/data

  --duplicate the action
  insert into flow.process_step_event_action(process_step_event_id, display_order, company_event_status_type_id, company_process_step_status_type_id,
                                             require_start_time, require_end_time, require_resource, always_enabled, multiple_uses, action_name, archived,
                                             date_created, date_modified, created_by_id, modified_by_id, hide_from_web, hide_from_mobile, color, content,
                                             action_type_id, bg_color)
    (select process_step_event_id, (select coalesce(max(display_order) + 1, 0)
                                    from flow.process_step_event_action
                                    where process_step_event_id = (select process_step_event_id from flow.process_step_event_action where id = p_process_step_event_action_id)
                                      and archived is not true), company_event_status_type_id, company_process_step_status_type_id,
                  require_start_time, require_end_time, require_resource, always_enabled, multiple_uses, concat(action_name, ' (copy)'), psea.archived,
                  now(), now(), p_current_user_id, p_current_user_id, hide_from_web, hide_from_mobile, color, content,
                  action_type_id, bg_color
    from flow.process_step_event_action psea
    inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
    inner join flow.process_step ps on pse.process_step_id = ps.id
    where psea.id = p_process_step_event_action_id
      and psea.archived is false
      and ps.company_id = p_company_id)
  returning id into v_new_event_action_id;

  --duplicate the non-archived logic
  insert into flow.process_step_event_logic(process_step_event_requirement_id, operation_type_id, sql_order, process_step_event_action_id, date_created, date_modified, created_by_id, modified_by_id, archived)
  (select process_step_event_requirement_id, operation_type_id, sql_order, v_new_event_action_id,
          now(), now(), p_current_user_id, p_current_user_id, psel.archived
    from flow.process_step_event_logic psel
      inner join flow.process_step_event_action psea on psel.process_step_event_action_id = psea.id
      inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
      inner join flow.process_step ps on pse.process_step_id = ps.id
    where psel.process_step_event_action_id = p_process_step_event_action_id
      and psea.archived is false
      and ps.company_id = p_company_id
      and psel.archived is false);

  return v_new_event_action_id;
END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
