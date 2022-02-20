-- DROP FUNCTION IF EXISTS brs.check_project_state(integer, character varying);
CREATE OR REPLACE FUNCTION brs.check_project_state(p_project_id INTEGER, p_state_abbreviation character varying)

RETURNS boolean
    LANGUAGE plpgsql
    AS $function$

-- select * from brs.check_project_state(62778, 'UT')
BEGIN

    --
    return (select coalesce( (
                select s.abbreviation = p_state_abbreviation
                from flow.project p
                inner join flow.company_state cs on p.company_state_id = cs.id
                inner join flow.state s on s.id = cs.state_id
                and p.id = p_project_id
        ), false) as result);

END
$function$
