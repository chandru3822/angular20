DROP FUNCTION if exists flow.get_work_queue_metrics_for_events(bigint);

CREATE OR REPLACE FUNCTION flow.get_work_queue_metrics_for_events(p_work_queue_type_id bigint)
  RETURNS table
          (
            work_queue_type_id                bigint,
--             work_queue_type                   varchar,
--             work_queue_category_id            bigint,
--             work_queue_type_display_order     bigint,
--             work_queue_category_display_order bigint,
--             use_event_data                    boolean,
--             smartlist_id                      bigint,
--             color                             varchar,
--             long_window                       bigint,
--             short_window                      bigint,
--             expected_cycle                    bigint,
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
--             work_queue_count                  bigint

          )
as
$$
declare
--   v_work_queue_type_id                bigint;
--   v_work_queue_type                   varchar;
--   v_work_queue_category_id            bigint;
--   v_work_queue_type_display_order     bigint;
--   v_work_queue_category_display_order bigint;
--   v_use_event_data                    boolean;
--   v_smartlist_id                      bigint;
--   v_color                             varchar;
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
--   v_current_count                     bigint;
BEGIN

--   select wqt.id,
--          wqt.work_queue_type,
--          wqt.work_queue_category_id,
--          wqt.display_order,
--          wqc.display_order,
--          wqt.use_event_data,
--          (select s.id from flow.smartlist s where s.work_queue_type_id = wqt.id),
--          wqc.color
--   into v_work_queue_type_id,
--     v_work_queue_type,
--     v_work_queue_category_id,
--     v_work_queue_type_display_order,
--     v_work_queue_category_display_order,
--     v_use_event_data,
--     v_smartlist_id,
--     v_color
--   from flow.work_queue_type wqt
--          inner join flow.work_queue_category wqc on wqt.work_queue_category_id = wqc.id
--   where wqt.id = p_work_queue_type_id;

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
  where wqt.id = p_work_queue_type_id;

  select (now() at time zone 'US/Mountain')::date,
         ((now() at time zone 'US/Mountain')::date - v_short_window)::date,
         ((now() at time zone 'US/Mountain')::date - v_long_window)::date
  into v_end_date,v_short_start_date,v_long_start_date;

  select count(*)
  into v_short_window_exited_wip
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                    on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
         inner join flow.process_step_event_work_queue_type pswqt2
                    on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
  where (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date
--     and  flow.get_difference_of_dates_by_duration(
--     (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
--     (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false;

  select count(*)
  into v_short_window_entered_wip
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                    on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
         inner join flow.process_step_event_work_queue_type pswqt2
                    on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
  where (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date
--     and  flow.get_difference_of_dates_by_duration(
--            (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
--            (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false;

  select count(*)
  into v_long_window_exited_wip
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                    on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
         inner join flow.process_step_event_work_queue_type pswqt2
                    on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
  where (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date
--     and  flow.get_difference_of_dates_by_duration(
--            (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
--            (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false;

  select count(*)
  into v_long_window_entered_wip
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                    on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
         inner join flow.process_step_event_work_queue_type pswqt2
                    on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
  where (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date
--     and  flow.get_difference_of_dates_by_duration(
--            (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
--            (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false;


  select count(*)
  into v_short_window_exited
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                    on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
         inner join flow.process_step_event_work_queue_type pswqt2
                    on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
  where (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date
    and flow.get_difference_of_dates_by_duration(
          (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
          (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 10
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false;

  select count(*)
  into v_short_window_entered
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                    on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
         inner join flow.process_step_event_work_queue_type pswqt2
                    on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
  where (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date
    and flow.get_difference_of_dates_by_duration(
          (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
          (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 10
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false;

  select count(*)
  into v_long_window_exited
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                    on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
         inner join flow.process_step_event_work_queue_type pswqt2
                    on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
  where (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date
    and flow.get_difference_of_dates_by_duration(
          (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
          (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 10
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false;

  select count(*)
  into v_long_window_entered
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
                    on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
         inner join flow.process_step_event_work_queue_type pswqt2
                    on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
  where (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date
    and flow.get_difference_of_dates_by_duration(
          (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
          (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 10
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false;

  select count(*) as short_window_numerator
  into v_short_window_numerator
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

    and case
          when wqc.date_exited_queue is not null then
                (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
                ((now() at time zone 'US/Mountain')::timestamp -
                 (wqt.short_window || ' ' || v_short_window_duration_type)::interval)::timestamp and
                flow.get_difference_of_dates_by_duration(
                  (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                  (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0 and
                case
                  when v_cycle_duration_type = 'Days' then
                      flow.get_difference_of_dates_by_duration(
                        (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                        (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 1) <=
                      v_expected_cycle
                  when v_cycle_duration_type = 'Hours' then
                      flow.get_difference_of_dates_by_duration(
                        (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                        (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 2) <=
                      v_expected_cycle
                  else
                      flow.get_difference_of_dates_by_duration(
                        (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                        (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 3) <=
                      v_expected_cycle
                  end
          else
            case
              when v_cycle_duration_type = 'Days' then
                  flow.get_difference_of_dates_by_duration((now() at time zone 'US/Mountain')::timestamp,
                                                           (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                                                           1) <=
                  v_expected_cycle
              when v_cycle_duration_type = 'Hours' then
                  flow.get_difference_of_dates_by_duration((now() at time zone 'US/Mountain')::timestamp,
                                                           (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                                                           2) <=
                  v_expected_cycle
              else
                  flow.get_difference_of_dates_by_duration((now() at time zone 'US/Mountain')::timestamp,
                                                           (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                                                           3) <=
                  v_expected_cycle
              end
    end;

  select count(*) as short_window_denominator
  into v_short_window_denominator
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

    and case
          when wqc.date_exited_queue is not null then
                (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
                ((now() at time zone 'US/Mountain')::timestamp -
                 (wqt.short_window || ' ' || v_short_window_duration_type)::interval)::timestamp and
                flow.get_difference_of_dates_by_duration(
                  (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                  (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
          else
            wqc.date_exited_queue is null
    end;


  select count(*) as long_window_numerator
  into v_long_window_numerator
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

    and case
          when wqc.date_exited_queue is not null then
                (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
                ((now() at time zone 'US/Mountain')::timestamp -
                 (wqt.long_window || ' ' || v_long_window_duration_type)::interval)::timestamp and
                flow.get_difference_of_dates_by_duration(
                  (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                  (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0 and
                case
                  when v_cycle_duration_type = 'Days' then
                      flow.get_difference_of_dates_by_duration(
                        (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                        (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 1) <=
                      v_expected_cycle
                  when v_cycle_duration_type = 'Hours' then
                      flow.get_difference_of_dates_by_duration(
                        (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                        (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 2) <=
                      v_expected_cycle
                  else
                      flow.get_difference_of_dates_by_duration(
                        (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                        (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 3) <=
                      v_expected_cycle
                  end

          else
            case
              when v_cycle_duration_type = 'Days' then
                  flow.get_difference_of_dates_by_duration((now() at time zone 'US/Mountain')::timestamp,
                                                           (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                                                           1) <=
                  v_expected_cycle
              when v_cycle_duration_type = 'Hours' then
                  flow.get_difference_of_dates_by_duration((now() at time zone 'US/Mountain')::timestamp,
                                                           (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                                                           2) <=
                  v_expected_cycle
              else
                  flow.get_difference_of_dates_by_duration((now() at time zone 'US/Mountain')::timestamp,
                                                           (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                                                           3) <=
                  v_expected_cycle
              end
    end;

  select count(*) as long_window_denominator
  into v_long_window_denominator
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

    and case
          when wqc.date_exited_queue is not null then
                (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
                ((now() at time zone 'US/Mountain')::timestamp -
                 (wqt.long_window || ' ' || v_long_window_duration_type)::interval)::timestamp and
                flow.get_difference_of_dates_by_duration(
                  (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                  (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
          else
            wqc.date_exited_queue is null
    end;

--   select count(*)
--   into v_current_count
--   from flow.work_queue_cycle wqc2
--          inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst2
--                     on wqc2.process_step_event_work_queue_type_event_status_type_id = pswqtpsst2.id
--          inner join flow.process_step_event_work_queue_type pswqt2
--                     on pswqtpsst2.process_step_event_work_queue_type_id = pswqt2.id
--   where date_exited_queue is null
--     and date_entered_queue is not null
--     and pswqt2.work_queue_type_id = p_work_queue_type_id
--     and pswqtpsst2.archived is false
--     and pswqt2.archived is false;

  return query
    select p_work_queue_type_id::bigint,
--            v_work_queue_type,
--            v_work_queue_category_id,
--            v_work_queue_type_display_order,
--            v_work_queue_category_display_order,
--            v_use_event_data,
--            v_smartlist_id,
--            v_color,
--            v_long_window,
--            v_short_window,
--            v_expected_cycle,
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
--            v_current_count;
END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
