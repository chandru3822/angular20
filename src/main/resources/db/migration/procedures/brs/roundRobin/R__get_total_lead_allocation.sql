drop function if exists brs.get_total_lead_allocation(p_round_robin_id bigint,
                                                      p_run_manual_allocation boolean ,
                                                      p_remote boolean);
CREATE OR REPLACE FUNCTION brs.get_total_lead_allocation(p_round_robin_id bigint,
                                                         p_run_manual_allocation boolean default false,
                                                         p_remote boolean default false)
    RETURNS table
            (
                round_robin_user_id        bigint,
                user_id                         bigint,
                company_timezone_id             bigint,
                timezone                        varchar,
                distance_from_actual_to_target  numeric,
                total_lead_allocation           numeric,
                actual_lead_allocation          numeric,
                score                           numeric,
                lead_gen_num                    bigint,
                lead_gen_den                    bigint,
                self_gen                        bigint,
                avail                           bigint,
                appointment_count_with_interval bigint,
                appointment_count               bigint,
                manual_allocation               numeric,
                lead_limit                      bigint,
                weekly_appointment_count        bigint
            )
AS
$BODY$
declare
  v_closer_gen_source_ids bigint[];
  v_users bigint[];
BEGIN

  select (select string_to_array(value, ',')
     from flow.company_configuration_value
     where code = 'CLOSER_GEN_SOURCE_IDS')::bigint[]
  into v_closer_gen_source_ids;

    return query
        select foo3.round_robin_user_id::bigint,
               foo3.user_id::bigint,
               foo3.company_timezone_id::bigint,
               foo3.timezone,
               foo3.actual_lead_allocation - foo3.total_lead_allocation as distance_from_actual_to_target,
               foo3.total_lead_allocation,
               foo3.actual_lead_allocation,
               foo3.score,
               foo3.lead_gen_num::bigint,
               foo3.lead_gen_den::bigint,
               foo3.self_gen::bigint,
               -1::bigint,
               foo3.appointment_count_with_interval::bigint,
              -1::bigint,
               foo3.manual_allocation,
               foo3.lead_limit::bigint,
               (select foo4.appointment_count from brs.get_appointment_count(foo3.user_id::bigint) as foo4) as weekly_appointment_count
        from (
                 select foo2.round_robin_user_id, foo2.user_id,
                        foo2.company_timezone_id, foo2.timezone,
                        foo2.actual_lead_allocation - foo2.total_lead_allocation as distance_from_actual_to_target,
                        case
                            when p_run_manual_allocation is true then
                                coalesce(foo2.manual_allocation,
                                         foo2.total_lead_allocation *
                                         (1 - coalesce(foo2.sum_manual_allocation::numeric,0::numeric))::numeric)::numeric
                            else foo2.total_lead_allocation end                  as total_lead_allocation,
                        foo2.actual_lead_allocation,
                        foo2.score,
                        foo2.lead_gen_num,
                        foo2.lead_gen_den,
                        foo2.self_gen,
                        foo2.appointment_count_with_interval,
                        foo2.manual_allocation,
                        foo2.lead_limit
                 from (
                          select foo1.round_robin_user_id, foo1.user_id,
                                 foo1.company_timezone_id, foo1.timezone,
                                 case
                                     when sum(foo1.score) over () = 0 then
                                         0
                                     else
                                         round(foo1.score / sum(foo1.score) over (), 10) end as total_lead_allocation,
                                 round(foo1.actual_lead_allocation, 10)                 as actual_lead_allocation,
                                 foo1.score                                       as score,
                                 foo1.lead_gen_num,
                                 foo1.lead_gen_den,
                                 foo1.self_gen,
                                 foo1.appointment_count_with_interval,
                                 foo1.manual_allocation,
                                 foo1.lead_limit,
                                 foo1.sum_manual_allocation
                          from (
                                   select foo.round_robin_user_id, foo.user_id,
                                          foo.company_timezone_id, foo.timezone,
                                   (select * from
                                     brs.get_lead_allocation_score(foo.lead_gen_num, foo.lead_gen_den,
                                     foo.self_gen, foo.manual_allocation,
                                     false)) as score,
                                          case
                                              when sum(foo.appointment_count_with_interval) over () = 0 then
                                                  0
                                              else foo.appointment_count_with_interval /
                                                   sum(foo.appointment_count_with_interval) over () end as actual_lead_allocation,
                                          foo.lead_gen_num,
                                          foo.lead_gen_den,
                                          foo.self_gen,
                                          foo.appointment_count_with_interval,
                                          foo.manual_allocation,
                                          foo.lead_limit,
                                          sum(foo.manual_allocation) over ()                        as sum_manual_allocation
                                   from (
                                            select pczu.id as round_robin_user_id,
                                                   pczu.user_id,
                                                   pczu.company_timezone_id,
                                                   t.timezone,
                                                   coalesce(fdc_counts.lead_gen_fdc_count, 0)                     as lead_gen_num,
                                                   coalesce(fdc_counts.lead_gen_appointment_count, 0)                     as lead_gen_den,
                                                   coalesce(fdc_counts.self_gen_fdc_count, 0)                          as self_gen,
                                                   coalesce(apcwi.appointment_count_with_interval, 0) as appointment_count_with_interval,
                                                   pczu.manual_allocation,
                                                  pczu.lead_limit
                                            from flow.round_robin_user pczu
                                                   inner join flow.company_user_status cus on cus.user_id = pczu.user_id
                                                   inner join flow.user_status_type ust
                                                              on cus.user_status_type_id = ust.id and ust.has_access is true and ust.company_id = 3 and ust.archived is false
                                                   INNER JOIN flow.user_position up ON up.user_id = pczu.user_id and up.archived is false and up.primary_flag is true
                                                   left join LATERAL brs.get_fdc_counts(pczu.user_id,up.id, v_closer_gen_source_ids,
                                                                                        90) fdc_counts on true
                                                   left join lateral brs.get_appointment_count_with_interval(pczu.user_id,v_closer_gen_source_ids,
                                                                                                             100) apcwi on true
                                                     left join flow.company_timezone ct on ct.id = pczu.company_timezone_id
                                                     left join flow.timezone t on t.id = ct.timezone_id
                                            where pczu.round_robin_id = p_round_robin_id and
                                              pczu.round_robin_user_type_id = 1 and
                                              pczu.archived is false
                                            group by pczu.id, pczu.user_id, pczu.company_timezone_id,
                                                     t.timezone, fdc_counts.lead_gen_fdc_count,lead_gen_appointment_count, fdc_counts.self_gen_fdc_count,
                                                     apcwi.appointment_count_with_interval,
                                                     pczu.manual_allocation, pczu.lead_limit) as foo
                                   group by foo.round_robin_user_id, foo.user_id, foo.company_timezone_id,
                                            foo.timezone, foo.lead_gen_num, foo.lead_gen_den, foo.self_gen,
                                            foo.appointment_count_with_interval,
                                            foo.manual_allocation, foo.lead_limit) as foo1) as foo2
                 group by foo2.round_robin_user_id, foo2.user_id, foo2.company_timezone_id,
                          foo2.timezone, foo2.actual_lead_allocation, foo2.total_lead_allocation,
                          foo2.total_lead_allocation, foo2.actual_lead_allocation, foo2.score,
                          foo2.lead_gen_num,
                          foo2.lead_gen_den,
                          foo2.self_gen,
                          foo2.appointment_count_with_interval,
                          foo2.manual_allocation,
                          foo2.lead_limit,
                          foo2.sum_manual_allocation) as foo3;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
