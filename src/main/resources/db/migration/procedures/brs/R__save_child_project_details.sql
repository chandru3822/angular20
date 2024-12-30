drop function if exists brs.save_child_project_details(p_parent_project_id bigint, p_user_id bigint, p_fields jsonb);
CREATE OR REPLACE FUNCTION brs.save_child_project_details(p_parent_project_id bigint, p_user_id bigint, p_fields jsonb)
  RETURNS void
  LANGUAGE plpgsql
AS
$function$
declare
    x jsonb;
    v_project_id bigint;
    v_cfga_id bigint;
    v_value text;
BEGIN

    for x in select jsonb_array_elements(p_fields)
        loop
            v_project_id := (x ->> 'projectId')::bigint;
            v_cfga_id := (x ->> 'customFieldGroupAssignmentId')::bigint;
            v_value := (x ->> 'value')::text;

--             raise notice 'proj is: %', v_project_id;
--             raise notice 'cfga is: %', v_cfga_id;
--             raise notice 'value is: %', v_value;

            perform flow.set_project_cfv(v_project_id, p_user_id, v_cfga_id, v_value, true);
        end loop;


END
$function$



