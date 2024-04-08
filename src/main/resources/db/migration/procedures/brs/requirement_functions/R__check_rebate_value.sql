DROP FUNCTION IF EXISTS brs.check_rebate_value(bigint, character varying);
CREATE OR REPLACE FUNCTION brs.check_rebate_value(p_project_id bigint, p_rebate_text character varying)

RETURNS boolean
    LANGUAGE plpgsql
    AS $function$
DECLARE
    v_proposal_id      bigint;
    v_rebate_value     numeric;
    v_rebate_has_value boolean = false;

BEGIN
    select pd.proposal_number_id into v_proposal_id
    from brs.project_details pd
    where pd.project_id = p_project_id;

    if(v_proposal_id is not null) then
       select plh.all_rebates->>p_rebate_text
        into v_rebate_value
           from brs.proposal_log_history plh
        where plh.id = v_proposal_id;

        if(v_rebate_value is not null) then
            v_rebate_has_value = (v_rebate_value::numeric) > 0;
        end if;
    end if;

    return v_rebate_has_value;
END
$function$
