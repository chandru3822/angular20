drop function if exists brs.get_allocation_by_zone(p_postal_code_zone_id bigint, p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.get_allocation_by_zone(p_postal_code_zone_id bigint, p_run_by_id bigint)
    RETURNS table
            (
                user_id                  bigint,
                postal_code_zone_user_id bigint,
                company_timezone_id      bigint,
                timezone                 varchar,
                zone_id                  bigint,
                full_name                character varying,
                prescribed_allocation    numeric,
                target_lead_allocation   numeric,
                manual_allocation        numeric,
                manual_allocation_whole  numeric
            )
AS
$BODY$
declare
  v_remote boolean default false;
BEGIN
    select remote
    into v_remote
    from flow.postal_code_zone
      where id = p_postal_code_zone_id;
    return query
        with prescribed as (
            select prescribed_lead_allocation.postal_code_zone_user_id,
                   prescribed_lead_allocation.user_id,
                   prescribed_lead_allocation.total_lead_allocation as prescribed_allocation
            from brs.get_total_lead_allocation(p_postal_code_zone_id,
                                               false,
                                               v_remote) prescribed_lead_allocation),
             target as (
                 select adjusted_allocation.postal_code_zone_user_id,
                        adjusted_allocation.user_id,
                        adjusted_allocation.company_timezone_id,
                        adjusted_allocation.timezone,
                        adjusted_allocation.total_lead_allocation,
                        adjusted_allocation.manual_allocation
                 from brs.get_total_lead_allocation(p_postal_code_zone_id,
                                                    true,
                                                    v_remote) adjusted_allocation)
        select t.user_id::bigint,
               t.postal_code_zone_user_id::bigint,
               t.company_timezone_id::bigint,
               t.timezone,
               p_postal_code_zone_id::bigint,
               concat(u.first_name, ' ', u.last_name)::character varying as full_name,
               p.prescribed_allocation,
               t.total_lead_allocation                                   as target_lead_allocation,
               t.manual_allocation,
               t.manual_allocation * 100                                 as manual_allocation_whole
        from target t
                 inner join prescribed p on p.user_id = t.user_id
                 inner join flow."user" u on u.id = t.user_id
        order by t.total_lead_allocation desc, p.prescribed_allocation desc, t.manual_allocation desc;

        insert into flow.company_function_log(function_name, parameters, run_by_id)
        values ('Get Allocation by Zone', 'p_postal_code_zone_id: ' || p_postal_code_zone_id ||
                                          ' p_run_by_id: ' || p_run_by_id,
                p_run_by_id);

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
