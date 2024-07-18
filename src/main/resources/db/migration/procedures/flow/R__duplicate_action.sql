-- drop function if exists flow.duplicate_action(bigint, bigint);
drop function if exists flow.duplicate_action(p_process_step_action_id bigint, p_current_user_id bigint, p_company_id bigint);
  CREATE OR REPLACE FUNCTION flow.duplicate_action(p_process_step_action_id bigint, p_current_user_id bigint, p_company_id bigint)
    returns bigint AS
$BODY$
declare
  v_new_action_id bigint;
  v_new_company_function_id bigint;
  r              record;
BEGIN
  -- the company_id comes from the login token, so it ensures the user has access to the company/data

  --duplicate the action
  insert into flow.process_step_action(process_step_id, action_type_id, action_name, company_process_step_status_type_id, company_process_step_status_type_ids, trigger_automatically,
                                       date_created, date_modified, created_by_id, modified_by_id, archived, always_enabled, display_order, time_based_trigger,
                                       company_project_status_type_id, hide_from_mobile, multiple_uses, remove_process_step_owner, hide_from_web, color, content, bg_color)
    (select process_step_id, action_type_id, concat(action_name, ' (copy)'),
            company_process_step_status_type_id, company_process_step_status_type_ids, trigger_automatically, now(), now(),
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
  insert into flow.process_step_action_logic(process_step_requirement_id, operation_type_id, sql_order, process_step_action_id, date_created, date_modified, created_by_id, modified_by_id, archived)
  (select process_step_requirement_id, operation_type_id, sql_order, v_new_action_id, now(),
          now(), p_current_user_id, p_current_user_id, psl.archived
    from flow.process_step_action_logic psl
      inner join flow.process_step_action psa on psl.process_step_action_id = psa.id
      inner join flow.process_step ps on psa.process_step_id = ps.id
    where psl.process_step_action_id = p_process_step_action_id
      and psa.archived is false
      and ps.company_id = p_company_id
      and psl.archived is false);


  --duplicate any child process steps
  insert into flow.process_step_action_child_process(process_step_action_id, process_step_id, display_order, archived, date_created, date_modified, created_by_id, modified_by_id, existing_company_process_step_status_type_id, initial_company_process_step_status_type_id)
  (select v_new_action_id, psacp.process_step_id,
          (select coalesce(max(display_order) + 1, 0)
           from flow.process_step_action_child_process as psacp
           where psacp.process_step_action_id = p_process_step_action_id
             and psacp.archived is false ),
          false, now(), now(), p_current_user_id, p_current_user_id, psacp.existing_company_process_step_status_type_id, psacp.initial_company_process_step_status_type_id
     from flow.process_step_action_child_process as psacp
     where psacp.process_step_action_id = p_process_step_action_id
     and psacp.archived is false);

  --duplicate any child functions
  for r in select *
           from flow.process_step_action_company_function psacf
            where psacf.process_step_action_id = p_process_step_action_id
            and psacf.archived is false
    loop
    --add the new function
      insert into flow.process_step_action_company_function(process_step_action_id, company_function_id, date_created, date_modified,
                                                            created_by_id, modified_by_id, archived, display_order)
      values (v_new_action_id, r.company_function_id, now(), now(), p_current_user_id, p_current_user_id, false,
              (select coalesce(max(p.display_order) + 1, 0)
               from flow.process_step_action_company_function as p
               where p.process_step_action_id = v_new_action_id
                 and p.archived is false)) returning id into v_new_company_function_id;

      --add the dynamic params for the new functions
      insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id, dynamic_value, created_by_id, modified_by_id)
      (select apdv.db_function_param_id, v_new_company_function_id, apdv.dynamic_value, p_current_user_id, p_current_user_id
       from flow.action_param_dynamic_value as apdv
       where apdv.archived is false
       and apdv.process_step_action_company_function_id = r.id);
    end loop;

  --duplicate any sms messages
  insert into flow.process_step_action_message_template(process_step_action_id, message_template_id, sms_team_ids, date_created, date_modified, created_by_id, modified_by_id, archived)
  (select v_new_action_id, psamt.message_template_id, psamt.sms_team_ids, now(), now(), p_current_user_id, p_current_user_id, false
     from flow.process_step_action_message_template psamt
     where psamt.process_step_action_id = p_process_step_action_id
     and psamt.archived is false);

  return v_new_action_id;
END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
