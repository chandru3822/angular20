drop function if exists brs.get_round_robin_lead_allocation_rank(p_round_robin_id bigint, p_time_interval bigint, p_run_by_id bigint);
drop function if exists brs.get_round_robin_lead_allocation_rank(p_round_robin_id bigint, p_start_date date,p_end_date date);
CREATE OR REPLACE FUNCTION brs.get_round_robin_lead_allocation_rank(p_round_robin_id bigint, p_start_date date,p_end_date date)
  RETURNS table
          (
            user_id              bigint,
            closer_name          text,
            lead_gen_fdc_percentage         numeric,
            self_gen_fdc             bigint,
            average_availability bigint,
            future_availability  numeric,
            score                numeric,
            rank                 bigint,
            rank_label text
          )
AS
$BODY$
declare
  v_closer_gen_source_ids bigint[];
  v_number_of_weeks numeric;
  v_future_availability date;
  v_time_interval bigint;
BEGIN
  select (select string_to_array(value, ',')
          from flow.company_configuration_value
          where code = 'CLOSER_GEN_SOURCE_IDS')::bigint[]
  into v_closer_gen_source_ids;

  select (p_end_date - p_start_date)::bigint
    into v_time_interval;

  v_future_availability = p_end_date + interval  '7 days';

  if v_time_interval < 7 then
    v_number_of_weeks = 1;
  else
    select (p_end_date - p_start_date)/7::numeric
    into v_number_of_weeks;
  end if;
-- raise notice 'v_number_of_weeks = %',v_number_of_weeks;
--   raise notice 'v_start_date = %',v_start_date;
--   raise notice 'v_end_date = %',v_end_date;
  return query
      with results as (select foo2.user_id::bigint,
                              foo2.closer_name,
                              foo2.lead_gen_fdc,
                              foo2.self_gen::bigint,
                              foo2.average_availability::bigint,
                              foo2.future_availability,
                              coalesce(foo2.manual_allocation,
                                       case
                                           when foo2.sum_manual_allocation is null then
                                               foo2.score
                                           else
                                                   foo2.score *
                                                   (1 - foo2.sum_manual_allocation::numeric)::numeric end)::numeric as score
                       from (select foo1.user_id,
                                    foo1.closer_name,
                                    foo1.lead_gen_fdc * 100 as lead_gen_fdc,
                                    foo1.self_gen,
                                    foo1.average_availability,
                                    foo1.future_availability,
                                    case
                                        when sum(foo1.score) = 0 then
                                            0
                                        else
                                            (round(foo1.score / sum(foo1.score) over (), 10))
                                        end                 as score,
                                    foo1.manual_allocation,
                                    foo1.sum_manual_allocation
                             from (select foo.user_id,
                                          brs.get_lead_allocation_score(foo.lead_gen_num, foo.lead_gen_den,
                                                                        foo.self_gen, foo.manual_allocation,
                                                                        false)                                 as score,
                                          case
                                              when foo.lead_gen_den is null or foo.lead_gen_den = 0 then
                                                  0
                                              else
                                                  round((foo.lead_gen_num / foo.lead_gen_den::numeric), 2) end as lead_gen_fdc,
                                          foo.average_availability                                             as average_availability,
                                          foo.future_availability,
                                          foo.self_gen,
                                          foo.closer_name,
                                          foo.manual_allocation,
                                          sum(foo.manual_allocation) over ()                                   as sum_manual_allocation
                                   from (select pczu.user_id,
                                                concat(u.first_name, ' ', u.last_name)                  as closer_name,
                                                coalesce(fdc_counts.lead_gen_fdc_count, 0)              as lead_gen_num,
                                                coalesce(fdc_counts.lead_gen_appointment_count, 0)      as lead_gen_den,
                                                coalesce(fdc_counts.total_fdc_count, 0)                 as lead_gen_num_fdc,
                                                coalesce(fdc_counts.self_gen_fdc_count, 0)              as self_gen,
                                                pczu.manual_allocation,
                                                (select coalesce(
                                                                (select ((sum(appointment_count)::numeric) / v_number_of_weeks)
                                                                 from brs.cached_appointment ca
                                                                 where ca.schedule_date between p_start_date and p_end_date
                                                                   and ca.user_id = pczu.user_id),
                                                                0))                                     as average_availability,
                                                (select coalesce((select ((sum(appointment_count)::numeric))
                                                                  from brs.cached_appointment ca
                                                                  where ca.schedule_date between p_end_date and v_future_availability
                                                                    and ca.user_id = pczu.user_id),
                                                                 0))                                    as future_availability
                                         from flow.round_robin pcz
                                                  inner join flow.round_robin_user pczu
                                                             on pczu.round_robin_id = pcz.id and pczu.archived is false
                                                  inner join flow.user u on u.id = pczu.user_id
                                                  INNER JOIN flow.user_position up ON up.user_id = u.id
                                                  INNER JOIN flow.company_user_status cus on cus.user_id = u.id
                             INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3   AND ust.has_access is true
                             left join LATERAL brs.get_fdc_counts(pczu.user_id,up.id, v_closer_gen_source_ids,
                                                                  v_time_interval) fdc_counts on true
                                         where pcz.id = p_round_robin_id
                                           and pczu.round_robin_user_type_id = 1
                                           and pcz.archived is false
                                           and up.archived is false
                                           and (up.end_date is null or
                                 up.end_date >= (now() at time zone 'US/Mountain')::date - (v_time_interval || 'day')::interval)
                                         group by pczu.user_id, up.id, concat(u.first_name, ' ', u.last_name),
                                                  pcz.distribution_time_frame_days,
                                                  pczu.manual_allocation, fdc_counts.lead_gen_appointment_count,
                                                  fdc_counts.lead_gen_fdc_count,
                                                  fdc_counts.total_fdc_count,
                                                  fdc_counts.self_gen_fdc_count,
                                                  fdc_counts.self_gen_fdc_count) as foo
                                   group by foo.user_id, foo.closer_name, foo.lead_gen_num, foo.lead_gen_den,
                                            foo.self_gen,
                                            foo.lead_gen_num_fdc,
                                            foo.manual_allocation,
                                            foo.average_availability,
                                            foo.future_availability) as foo1
                             group by foo1.score, foo1.average_availability, foo1.user_id, foo1.closer_name,
                                      foo1.lead_gen_fdc,
                                      foo1.self_gen, foo1.manual_allocation, foo1.future_availability,
                                      foo1.sum_manual_allocation, coalesce(foo1.average_availability, 0),
                                      coalesce(foo1.score, 0)) as foo2
                       group by foo2.user_id, foo2.closer_name, foo2.lead_gen_fdc, foo2.self_gen,
                                foo2.average_availability,
                                foo2.future_availability,
                                coalesce(foo2.manual_allocation,
                                         case
                                             when foo2.sum_manual_allocation is null then
                                                 foo2.score
                                             else
                                                     foo2.score *
                                                     (1 - foo2.sum_manual_allocation::numeric)::numeric end)::numeric)
      select r.user_id,
             r.closer_name,
             r.lead_gen_fdc as lead_gen_fdc_percentage,
             r.self_gen as self_gen_fdc,
             r.average_availability,
             r.future_availability,
             r.score,
             rank() OVER (ORDER BY r.score DESC) rank,
             CASE
                 WHEN COUNT(*) OVER (PARTITION BY r.score) > 1 THEN 'T' || rank() OVER (ORDER BY r.score DESC)
                 ELSE rank() OVER (ORDER BY r.score DESC)::text
                 END AS rank_label
      from results r
      order by r.score desc, r.closer_name;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
