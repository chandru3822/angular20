DROP FUNCTION if exists flow.get_combined_work_queue_metrics(bigint);

CREATE OR REPLACE FUNCTION flow.get_combined_work_queue_metrics(p_work_queue_type_id bigint, p_use_event_data boolean)
  RETURNS table
          (
            work_queue_type_id                bigint,
            short_window_numerator            bigint,
            short_window_denominator          bigint,
            long_window_numerator             bigint,
            long_window_denominator           bigint,
            short_window_percentage           numeric,
            long_window_percentage            numeric,
            short_window_duration_type        varchar,
            long_window_duration_type         varchar,
            expected_cycle_duration_type      varchar,
            expected_target                   numeric,
            inverse_expectation               boolean,
            short_window_entered              bigint,
            short_window_exited               bigint,
            long_window_entered               bigint,
            long_window_exited                bigint,
            short_wip                         bigint,
            long_wip                          bigint
          )
as
$$
declare
  v_long_window                       integer;
  v_short_window                      integer;
  v_long_window_duration_type_id      bigint;
  v_short_window_duration_type_id     bigint;
  v_expected_cycle                    bigint;
  v_expected_cycle_duration_type_id   bigint;
  v_expected_target                   numeric;
  v_inverse_expectation               boolean;
  v_short_window_duration_type        varchar;
  v_long_window_duration_type         varchar;
  v_cycle_duration_type               varchar;
  v_short_window_numerator            bigint;
  v_short_window_denominator          bigint;
  v_long_window_numerator             bigint;
  v_long_window_denominator           bigint;
  v_end_date                          date;
  v_short_start_date                  date;
  v_long_start_date                   date;
  v_short_window_entered_wip          bigint;
  v_short_window_exited_wip           bigint;
  v_long_window_entered_wip           bigint;
  v_long_window_exited_wip            bigint;
  v_short_window_entered              bigint;
  v_short_window_exited               bigint;
  v_long_window_entered               bigint;
  v_long_window_exited                bigint;
  v_now_date date;
  v_now_timestamp timestamp;
BEGIN

  select wqt.long_window,
         wqt.short_window,
         wqt.long_window_duration_type_id,
         wqt.short_window_duration_type_id,
         wqt.expected_cycle,
         wqt.expected_cycle_duration_type_id,
         wqt.expected_target,
         wqt.inverse_expectation,
         dt_short_window.duration_type,
         dt_long_window.duration_type,
         dt_cycle_duration.duration_type
  into
    v_long_window,
    v_short_window,
    v_long_window_duration_type_id,
    v_short_window_duration_type_id,
    v_expected_cycle,
    v_expected_cycle_duration_type_id,
    v_expected_target,
    v_inverse_expectation,
    v_short_window_duration_type,
    v_long_window_duration_type,
    v_cycle_duration_type
  from flow.work_queue_type wqt
         inner join flow.duration_type dt_short_window on wqt.short_window_duration_type_id = dt_short_window.id
         inner join flow.duration_type dt_long_window on wqt.long_window_duration_type_id = dt_long_window.id
         inner join flow.duration_type dt_cycle_duration on wqt.expected_cycle_duration_type_id = dt_cycle_duration.id
         inner join flow.work_queue_category wqc on wqt.work_queue_category_id = wqc.id
  where wqt.id = p_work_queue_type_id;

  select (now() at time zone 'US/Mountain')::date,
         (now() at time zone 'US/Mountain')::timestamp
         into v_now_date, v_now_timestamp;

  select v_now_date::date,
         (v_now_date - v_short_window)::date,
         (v_now_date - v_long_window)::date
  into v_end_date,v_short_start_date,v_long_start_date;

  drop table if exists randa_wqc_values;

  raise notice 'wqt_id %',p_work_queue_type_id;
  raise notice 'use_event_data %',p_use_event_data;

  if(p_use_event_data) then
    create temp table randa_wqc_values as (
      select wqc2.id,
             (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date as date_entered_queue_date,
             (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date as date_exited_queue_date,
             (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp as date_entered_queue_timestamp,
             (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp as date_exited_queue_timestamp
      from flow.work_queue_cycle wqc2
             inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                        on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
             inner join flow.process_step_event_work_queue_type pswqt2
                        on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
      where pswqt2.work_queue_type_id = p_work_queue_type_id
        and pswqtpsst2.archived is false
        and pswqt2.archived is false
        and (
        --todo: i actually think the v_long_start_date would cover both scenarios here
--         ((date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date)
--         OR
--         ((date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date)
--         OR
          ((date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date)
          OR
          ((date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date)
        )
    );
  else
    create temp table randa_wqc_values as (

      select wqc2.id,
             (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date as date_entered_queue_date,
             (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date as date_exited_queue_date,
             (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp as date_entered_queue_timestamp,
             (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp as date_exited_queue_timestamp
      from flow.work_queue_cycle wqc2
             inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                        on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
             inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
      where pswqt2.work_queue_type_id = p_work_queue_type_id
        and pswqtpsst2.archived is false
        and pswqt2.archived is false
      and (
        --todo: i actually think the v_long_start_date would cover both scenarios here
  --         ((date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date)
  --         OR
  --         ((date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date)
  --         OR
          ((date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date)
          OR
          ((date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date)
        )
    );
  end if;
  select count(1) filter (where date_exited_queue_date between v_short_start_date and v_end_date),
         count(1) filter (where date_entered_queue_date between v_short_start_date and v_end_date),
         count(1) filter (where date_exited_queue_date between v_long_start_date and v_end_date),
         count(1) filter (where date_entered_queue_date between v_long_start_date and v_end_date),
         count(1) filter (where date_exited_queue_date between v_short_start_date and v_end_date
           and flow.get_difference_of_dates_by_duration(
                 date_exited_queue_timestamp,
                 date_entered_queue_timestamp, 4) > 10),
         count(1) filter (where date_entered_queue_date between v_short_start_date and v_end_date
           and flow.get_difference_of_dates_by_duration(
                 date_exited_queue_timestamp,
                 date_entered_queue_timestamp, 4) > 10),
         count(1) filter (where date_exited_queue_date between v_long_start_date and v_end_date
           and flow.get_difference_of_dates_by_duration(
                 date_exited_queue_timestamp,
                 date_entered_queue_timestamp, 4) > 10),
         count(1) filter (where date_entered_queue_date between v_long_start_date and v_end_date
           and flow.get_difference_of_dates_by_duration(
                 date_exited_queue_timestamp,
                 date_entered_queue_timestamp, 4) > 10)
  into v_short_window_exited_wip, v_short_window_entered_wip,
    v_long_window_exited_wip, v_long_window_entered_wip,
    v_short_window_exited, v_short_window_entered,
    v_long_window_exited, v_long_window_entered
  from randa_wqc_values;

  drop table if exists randa_wqc_other;

  if(p_use_event_data) then
    create temp table randa_wqc_other as (
      select wqc.id,
             wqt.short_window,
             wqt.long_window,
             (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp as date_entered_queue_timestamp,
             (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp as date_exited_queue_timestamp
      from flow.work_queue_cycle wqc
             inner join flow.company_event_status_type cest
                        on wqc.company_event_status_type_id = cest.id and cest.archived is false
             inner join flow.event_status_type est
                        on est.id = cest.event_status_type_id and est.archived is false
             inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                        on wqc.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
             inner join flow.process_step_event_work_queue_type pswqt
                        on pswqtpsst2.process_step_event_work_queue_type_id = pswqt.id
             inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id and wqt.archived is false
             inner join flow.work_queue_category wqct on wqct.id = wqt.work_queue_category_id and wqct.archived is false
      where wqt.id = p_work_queue_type_id
        and (
          date_exited_queue is null
          OR
          ((wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
           (v_now_timestamp - (wqt.short_window || ' ' || v_short_window_duration_type)::interval)::timestamp)
          OR
          ((wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
           (v_now_timestamp -
            (wqt.long_window || ' ' || v_long_window_duration_type)::interval)::timestamp)
        )
    );
  else
    create temp table randa_wqc_other as (
      select wqc.id,
             wqt.short_window,
             wqt.long_window,
             (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp as date_entered_queue_timestamp,
             (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp as date_exited_queue_timestamp
      from flow.work_queue_cycle wqc
      inner join flow.company_process_step_status_type cpsst
      on wqc.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
      inner join flow.process_step_status_type psst
      on psst.id = cpsst.process_step_status_type_id and psst.archived is false
      inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
      on pswqtpsst.id = wqc.process_step_work_queue_type_process_step_status_type_id and
      pswqtpsst.archived is false
      inner join flow.process_step_work_queue_type pswqt
      on pswqtpsst.process_step_work_queue_type_id = pswqt.id and pswqt.archived is false
      inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id and wqt.archived is false
      inner join flow.work_queue_category wqct on wqct.id = wqt.work_queue_category_id and wqct.archived is false
      where wqt.id = p_work_queue_type_id
        and (
          date_exited_queue is null
          OR
          ((wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
          (v_now_timestamp - (wqt.short_window || ' ' || v_short_window_duration_type)::interval)::timestamp)
          OR
          ((wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
          (v_now_timestamp -
           (wqt.long_window || ' ' || v_long_window_duration_type)::interval)::timestamp)
        )
    );
  end if;
  select count(1) as short_window_numerator
  into v_short_window_numerator
  from randa_wqc_other wqc
    where case
          when wqc.date_exited_queue_timestamp is not null then
                date_exited_queue_timestamp >=
                (v_now_timestamp -
                 (wqc.short_window || ' ' || v_short_window_duration_type)::interval)::timestamp and
                flow.get_difference_of_dates_by_duration(
                  date_exited_queue_timestamp,
                  date_entered_queue_timestamp, 4) > 0 and
                case
                  when v_cycle_duration_type = 'Days' then
                      flow.get_difference_of_dates_by_duration(
                        date_exited_queue_timestamp,
                        date_entered_queue_timestamp, 1) <=
                      v_expected_cycle
                  when v_cycle_duration_type = 'Hours' then
                      flow.get_difference_of_dates_by_duration(
                        date_exited_queue_timestamp,
                        date_entered_queue_timestamp, 2) <=
                      v_expected_cycle
                  else
                      flow.get_difference_of_dates_by_duration(
                        date_exited_queue_timestamp,
                        date_entered_queue_timestamp, 3) <=
                      v_expected_cycle
                  end
          else
            case
              when v_cycle_duration_type = 'Days' then
                  flow.get_difference_of_dates_by_duration(v_now_timestamp,
                                                           date_entered_queue_timestamp,
                                                           1) <=
                  v_expected_cycle
              when v_cycle_duration_type = 'Hours' then
                  flow.get_difference_of_dates_by_duration(v_now_timestamp,
                                                           date_entered_queue_timestamp,
                                                           2) <=
                  v_expected_cycle
              else
                  flow.get_difference_of_dates_by_duration(v_now_timestamp,
                                                           date_entered_queue_timestamp,
                                                           3) <=
                  v_expected_cycle
              end
    end;

  select count(1) as short_window_denominator
  into v_short_window_denominator
  from randa_wqc_other wqc
  where case
          when date_exited_queue_timestamp is not null then
                date_exited_queue_timestamp >=
                (v_now_timestamp -
                 (wqc.short_window || ' ' || v_short_window_duration_type)::interval)::timestamp and
                flow.get_difference_of_dates_by_duration(
                  date_exited_queue_timestamp,
                  date_entered_queue_timestamp, 4) > 0
          else
            date_exited_queue_timestamp is null
    end;


  select count(1) as long_window_numerator
  into v_long_window_numerator
  from randa_wqc_other wqc
  where case
          when date_exited_queue_timestamp is not null then
                date_exited_queue_timestamp >=
                (v_now_timestamp -
                 (wqc.long_window || ' ' || v_long_window_duration_type)::interval)::timestamp and
                flow.get_difference_of_dates_by_duration(
                  date_exited_queue_timestamp,
                  date_entered_queue_timestamp, 4) > 0 and
                case
                  when v_cycle_duration_type = 'Days' then
                      flow.get_difference_of_dates_by_duration(
                        date_exited_queue_timestamp,
                        date_entered_queue_timestamp, 1) <=
                      v_expected_cycle
                  when v_cycle_duration_type = 'Hours' then
                      flow.get_difference_of_dates_by_duration(
                        date_exited_queue_timestamp,
                        date_entered_queue_timestamp, 2) <=
                      v_expected_cycle
                  else
                      flow.get_difference_of_dates_by_duration(
                        date_exited_queue_timestamp,
                        date_entered_queue_timestamp, 3) <=
                      v_expected_cycle
                  end

          else
            case
              when v_cycle_duration_type = 'Days' then
                  flow.get_difference_of_dates_by_duration(v_now_timestamp,
                                                           date_entered_queue_timestamp,
                                                           1) <=
                  v_expected_cycle
              when v_cycle_duration_type = 'Hours' then
                  flow.get_difference_of_dates_by_duration(v_now_timestamp,
                                                           date_entered_queue_timestamp,
                                                           2) <=
                  v_expected_cycle
              else
                  flow.get_difference_of_dates_by_duration(v_now_timestamp,
                                                           date_entered_queue_timestamp,
                                                           3) <=
                  v_expected_cycle
              end
    end;

  select count(1) as long_window_denominator
  into v_long_window_denominator
  from randa_wqc_other wqc
  where case
          when date_exited_queue_timestamp is not null then
                date_exited_queue_timestamp >=
                (v_now_timestamp -
                 (wqc.long_window || ' ' || v_long_window_duration_type)::interval)::timestamp and
                flow.get_difference_of_dates_by_duration(
                  date_exited_queue_timestamp,
                  date_entered_queue_timestamp, 4) > 0
          else
            date_exited_queue_timestamp is null
    end;

  return query
    select p_work_queue_type_id::bigint,
           v_short_window_numerator::bigint,
           v_short_window_denominator::bigint,
           v_long_window_numerator::bigint,
           v_long_window_denominator::bigint,
           case
             when v_short_window_numerator = 0 and v_short_window_denominator = 0 then
               1
             else
               round((v_short_window_numerator / case
                                                   when v_short_window_denominator = 0 then 1
                                                   else v_short_window_denominator::numeric end)::numeric, 2) end,
           case
             when v_long_window_numerator = 0 and v_long_window_denominator = 0 then
               1
             else
               round((v_long_window_numerator /
                      case
                        when v_long_window_denominator = 0 then 1
                        else v_long_window_denominator::numeric end)::numeric,
                     2) end,
           v_short_window_duration_type,
           v_long_window_duration_type,
           v_cycle_duration_type,
           v_expected_target,
           v_inverse_expectation,
           v_short_window_entered::bigint,
           v_short_window_exited::bigint,
           v_long_window_entered::bigint,
           v_long_window_exited::bigint,
           (v_short_window_entered_wip - v_short_window_exited_wip)::bigint,
           (v_long_window_entered_wip - v_long_window_exited_wip)::bigint;
END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
