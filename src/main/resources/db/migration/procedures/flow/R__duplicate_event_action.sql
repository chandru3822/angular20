-- drop function if exists flow.duplicate_event_action(bigint, bigint);
drop function if exists flow.duplicate_event_action(p_process_step_event_action_id bigint, p_current_user_id bigint, p_company_id bigint);
  CREATE OR REPLACE FUNCTION flow.duplicate_event_action(p_process_step_event_action_id bigint, p_current_user_id bigint, p_company_id bigint)
    returns bigint AS
$BODY$
declare
    v_new_event_action_id bigint;
    v_new_company_function_id bigint;
    r              record;
BEGIN
  -- the company_id comes from the login token, so it ensures the user has access to the company/data

  --duplicate the action
  insert into flow.process_step_event_action(process_step_event_id, display_order, company_event_status_type_id, company_process_step_status_type_id,
                                             require_start_time, require_end_time, require_resource, always_enabled, multiple_uses, action_name, archived,
                                             date_created, date_modified, created_by_id, modified_by_id, hide_from_web, hide_from_mobile, color, content,
                                             action_type_id, bg_color, show_on_cancelled_completed_events, show_on_cancelled_completed_process_step)
    (select process_step_event_id, (select coalesce(max(display_order) + 1, 0)
                                    from flow.process_step_event_action
                                    where process_step_event_id = (select process_step_event_id from flow.process_step_event_action where id = p_process_step_event_action_id)
                                      and archived is not true), company_event_status_type_id, company_process_step_status_type_id,
                  require_start_time, require_end_time, require_resource, always_enabled, multiple_uses, concat(action_name, ' (copy)'), psea.archived,
                  now(), now(), p_current_user_id, p_current_user_id, hide_from_web, hide_from_mobile, color, content,
                  action_type_id, bg_color, psea.show_on_cancelled_completed_events, psea.show_on_cancelled_completed_process_step
    from flow.process_step_event_action psea
    inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
    inner join flow.process_step ps on pse.process_step_id = ps.id
    where psea.id = p_process_step_event_action_id
      and psea.archived is false
      and ps.company_id = p_company_id)
  returning id into v_new_event_action_id;

  --duplicate the non-archived logic
  insert into flow.process_step_event_action_logic(process_step_event_requirement_id, operation_type_id, sql_order, process_step_event_action_id, date_created, date_modified, created_by_id, modified_by_id, archived)
  (select process_step_event_requirement_id, operation_type_id, sql_order, v_new_event_action_id,
          now(), now(), p_current_user_id, p_current_user_id, psel.archived
    from flow.process_step_event_action_logic psel
      inner join flow.process_step_event_action psea on psel.process_step_event_action_id = psea.id
      inner join flow.process_step_event pse on psea.process_step_event_id = pse.id
      inner join flow.process_step ps on pse.process_step_id = ps.id
    where psel.process_step_event_action_id = p_process_step_event_action_id
      and psea.archived is false
      and ps.company_id = p_company_id
      and psel.archived is false);

  --duplicate required/optional fields
  insert into flow.process_step_event_action_field(process_step_event_action_id, custom_field_group_assignment_id, required, archived, date_created, date_modified, created_by_id, modified_by_id)
  (select v_new_event_action_id, pseaf.custom_field_group_assignment_id, pseaf.required, false, now(), now(), p_current_user_id, p_current_user_id
   from flow.process_step_event_action_field pseaf
   where pseaf.process_step_event_action_id = p_process_step_event_action_id
   and pseaf.archived is false);

--duplicate any child functions
  for r in select *
           from flow.process_step_event_action_company_function psacf
           where psacf.process_step_event_action_id = p_process_step_event_action_id
             and psacf.archived is false
    loop
      --add the new function
      insert into flow.process_step_event_action_company_function(process_step_event_action_id, company_function_id, date_created, date_modified,
                                                            created_by_id, modified_by_id, archived, display_order)
      values (v_new_event_action_id, r.company_function_id, now(), now(), p_current_user_id, p_current_user_id, false,
              (select coalesce(max(p.display_order) + 1, 0)
               from flow.process_step_action_company_function as p
               where p.process_step_action_id = v_new_event_action_id
                 and p.archived is false)) returning id into v_new_company_function_id;

      --add the dynamic params for the new functions
      insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, modified_by_id, process_step_event_action_company_function_id)
        (select apdv.db_function_param_id, null, apdv.dynamic_value, p_current_user_id, p_current_user_id, v_new_company_function_id
         from flow.action_param_dynamic_value as apdv
         where apdv.archived is false
           and apdv.process_step_event_action_company_function_id = r.id);
    end loop;

  return v_new_event_action_id;

END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
