CREATE OR REPLACE FUNCTION brs.limit_by_org_for_closers(p_user_ids integer[], p_org_ids integer[], p_date_created date)
    RETURNS integer[]
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN (select array(
            select up.user_id
	        from flow.user_position up
            where up.position_id = 1 --Closer
                and up.org_id is not null
                and up.org_id = any(p_org_ids)
                and up.user_id = any(p_user_ids)
                and case when up.end_date is not null then
                    p_date_created between up.start_date and up.end_date
                    else p_date_created >= up.start_date
                    end
	    ));
    END
$function$
