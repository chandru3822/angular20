CREATE OR REPLACE FUNCTION brs.limit_by_org_for_setters(p_user_ids integer[], p_org_ids integer[], p_date_created date)
    RETURNS integer[]
    LANGUAGE plpgsql
AS $function$
    BEGIN
        RETURN (select array(
            select distinct up.user_id
            from flow.user_position up
            where up.position_id in (select unnest(string_to_array(value, ',')::int[])
                                     from flow.company_configuration_value
                                     where code = 'SETTER_POSITION_IDS') --(Setter, Setter Manager)
                and up.org_id is not null
                and case when ARRAY_LENGTH( p_org_ids, 1 ) > 1 then
                           up.org_id = any(p_org_ids) else 1=1 end
                and up.user_id = any(p_user_ids)
                and case when up.end_date is not null then
                    p_date_created between up.start_date and up.end_date
                    else p_date_created >= up.start_date
                    end
        ));
    END
$function$
