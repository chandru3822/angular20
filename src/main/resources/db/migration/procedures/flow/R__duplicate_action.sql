-- drop function if exists flow.duplicate_action(int, int);
CREATE OR REPLACE FUNCTION flow.duplicate_action(p_process_step_action_id int, p_current_user_id int, p_company_id int)
    returns int AS
$BODY$
declare
    v_new_action_id int;
BEGIN
  -- the company_id comes from the login token, so it ensures the user has access to the company/data

  --duplicate the action
  insert into flow.process_step_action(process_step_id, action_type_id, action_name, company_process_step_status_type_id, trigger_automatically,
                                       date_created, date_modified, created_by_id, modified_by_id, archived, always_enabled, display_order, time_based_trigger,
                                       company_project_status_type_id, hide_from_mobile, multiple_uses, remove_process_step_owner, hide_from_web, color, content, bg_color)
    (select process_step_id, action_type_id, concat(action_name, ' (copy)'),
            company_process_step_status_type_id, trigger_automatically, now(), now(),
            p_current_user_id, p_current_user_id, psa.archived, always_enabled,  (select coalesce(max(display_order) + 1, 0)
                                                                                  from flow.process_step_action
                                                                                  where process_step_id = (select process_step_id from flow.process_step_action where id = p_process_step_action_id)
                                                                                    and archived is not true), time_based_trigger,
            company_project_status_type_id, hide_from_mobile, multiple_uses, remove_process_step_owner, hide_from_web,
            color, content, bg_color
    from flow.process_step_action psa
    inner join flow.process_step ps on psa.process_step_id = ps.id
    where psa.id = p_process_step_action_id
      and psa.archived is false
      and ps.company_id = p_company_id)
  returning id into v_new_action_id;

  --duplicate the non-archived logic
  insert into flow.process_step_logic(process_step_requirement_id, operation_type_id, sql_order, process_step_action_id, date_created, date_modified, created_by_id, modified_by_id, archived)
  (select process_step_requirement_id, operation_type_id, sql_order, v_new_action_id, now(),
          now(), p_current_user_id, p_current_user_id, psl.archived
    from flow.process_step_logic psl
      inner join flow.process_step_action psa on psl.process_step_action_id = psa.id
      inner join flow.process_step ps on psa.process_step_id = ps.id
    where psl.process_step_action_id = p_process_step_action_id
      and psa.archived is false
      and ps.company_id = p_company_id
      and psl.archived is false);

  return v_new_action_id;
END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
