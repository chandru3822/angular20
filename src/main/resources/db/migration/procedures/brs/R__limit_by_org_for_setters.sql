CREATE OR REPLACE FUNCTION brs.limit_by_org_for_setters(p_user_ids integer[], p_org_ids integer[], p_added_on date)
    RETURNS integer[]
    LANGUAGE plpgsql
AS $function$
    BEGIN
        select array(
            select up.user_id
            from flow.user_position up
            where up.position_id = 4 and ((Array[up.org_id] <@ p_org_ids))
                and Array[up.user_id] <@ p_user_ids
                and case when up.end_date is not null then
                    p_added_on between up.start_date and up.end_date
                    else p_added_on >= up.start_date
                    end
        );
    END
$function$
