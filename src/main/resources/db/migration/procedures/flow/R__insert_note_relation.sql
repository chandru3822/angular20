drop function if exists flow.insert_note_relation(p_primary_id bigint, p_note_id bigint, p_object_type_id bigint, p_user_id bigint);
  CREATE OR REPLACE FUNCTION flow.insert_note_relation(p_primary_id bigint, p_note_id bigint, p_object_type_id bigint, p_user_id bigint)

RETURNS boolean
    LANGUAGE plpgsql
    AS $function$

-- NOTE: this returns true cuz with VOID Java was pissing me off and saying it was returning a value when one wasn't expected

BEGIN

    --select * from flow.get_notes(111112, 2);
    case when p_object_type_id = 1 then
            insert into flow.project_note(project_id, note_id)
                values (p_primary_id, p_note_id);
            return true;
    when p_object_type_id = 2 then
            insert into flow.contact_note(contact_id, note_id)
            values (p_primary_id, p_note_id);
            return true;
    when p_object_type_id = 3 then
        insert into flow.user_note(user_id, note_id)
        values (p_primary_id, p_note_id);
        return true;
    when p_object_type_id = 4 then
        insert into flow.project_process_step_note(project_process_step_id, note_id)
        values (p_primary_id, p_note_id);
        return true;
    when p_object_type_id = 5 then
      insert into flow.org_note(org_id, note_id)
      values (p_primary_id, p_note_id);
      return true;
    end case;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Insert Note Relation', 'p_primary_id: ' || p_primary_id ||
                                    ' p_note_id: ' || p_note_id ||
                                    ' p_object_type_id: ' || p_object_type_id ||
                                    ' p_user_id: ' || p_user_id,
            p_user_id);

END;
$function$
