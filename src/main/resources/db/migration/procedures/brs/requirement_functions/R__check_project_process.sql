 DROP FUNCTION IF EXISTS brs.check_project_process(bigint, bigint);
CREATE OR REPLACE FUNCTION brs.check_project_process(p_project_id bigint, p_company_process_id bigint)

RETURNS boolean
    LANGUAGE plpgsql
    AS $function$

BEGIN

    --
    return exists (
        select id
        from flow.project
        where id = p_project_id
          and company_process_id = p_company_process_id
          and archived is not true
    );

END
$function$
