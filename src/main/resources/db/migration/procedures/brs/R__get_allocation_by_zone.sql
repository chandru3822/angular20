CREATE OR REPLACE FUNCTION brs.get_allocation_by_zone(p_postal_code_zone_id integer)
    RETURNS table
            (
                user_id                  integer,
                postal_code_zone_user_id integer,
                zone_id                  integer,
                full_name                character varying,
                prescribed_allocation    numeric,
                target_lead_allocation   numeric,
                manual_allocation        numeric,
                manual_allocation_whole  numeric
            )
AS
$BODY$
BEGIN
    return query
        with prescribed as (
            select prescribed_lead_allocation.postal_code_zone_user_id,
                   prescribed_lead_allocation.user_id,
                   prescribed_lead_allocation.total_lead_allocation as prescribed_allocation
            from brs.get_total_lead_allocation(p_postal_code_zone_id,
                                               false) prescribed_lead_allocation),
             target as (
                 select adjusted_allocation.postal_code_zone_user_id,
                        adjusted_allocation.user_id,
                        adjusted_allocation.total_lead_allocation,
                        adjusted_allocation.manual_allocation
                 from brs.get_total_lead_allocation(p_postal_code_zone_id,
                                                    true) adjusted_allocation)
        select t.user_id,
               t.postal_code_zone_user_id,
               p_postal_code_zone_id,
               concat(u.first_name, ' ', u.last_name)::character varying as full_name,
               p.prescribed_allocation,
               t.total_lead_allocation                                   as target_lead_allocation,
               t.manual_allocation,
               t.manual_allocation * 100                                 as manual_allocation_whole
        from target t
                 inner join prescribed p on p.user_id = t.user_id
                 inner join flow."user" u on u.id = t.user_id
        order by t.total_lead_allocation desc, p.prescribed_allocation desc, t.manual_allocation desc;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
