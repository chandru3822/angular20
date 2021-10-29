DROP FUNCTION if exists flow.get_work_queue_metrics(integer);

CREATE OR REPLACE FUNCTION flow.get_work_queue_metrics(p_work_queue_type_id integer)
  RETURNS table
          (
            short_window_numerator       bigint,
            short_window_denominator     bigint,
            long_window_numerator        bigint,
            long_window_denominator      bigint,
            short_window_percentage      numeric,
            long_window_percentage       numeric,
            short_window_duration_type   varchar,
            long_window_duration_type    varchar,
            expected_cycle_duration_type varchar,
            expected_target              numeric,
            inverse_expectation          boolean,
            short_window_entered         bigint,
            short_window_exited          bigint,
            long_window_entered          bigint,
            long_window_exited           bigint,
            short_wip                    bigint,
            long_wip                     bigint

          )
as
$$
declare
  v_long_window                     integer;
  v_short_window                    integer;
  v_long_window_duration_type_id    integer;
  v_short_window_duration_type_id   integer;
  v_expected_cycle                  integer;
  v_expected_cycle_duration_type_id integer;
  v_expected_target                 numeric;
  v_inverse_expectation             boolean;
  v_short_window_duration_type      varchar;
  v_long_window_duration_type       varchar;
  v_cycle_duration_type             varchar;
  v_short_window_numerator          bigint;
  v_short_window_denominator        bigint;
  v_long_window_numerator           bigint;
  v_long_window_denominator         bigint;
  v_end_date                        date;
  v_short_start_date                date;
  v_long_start_date                 date;
  v_short_window_entered_wip            bigint;
  v_short_window_exited_wip             bigint;
  v_long_window_entered_wip             bigint;
  v_long_window_exited_wip              bigint;
  v_short_window_entered            bigint;
  v_short_window_exited             bigint;
  v_long_window_entered             bigint;
  v_long_window_exited              bigint;
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
  into v_long_window,
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
         inner join flow.duration_type dt_cycle_duration
                    on wqt.expected_cycle_duration_type_id = dt_cycle_duration.id
  where wqt.id = p_work_queue_type_id;

  select (now() at time zone 'US/Mountain')::date,
         ((now() at time zone 'US/Mountain')::date - v_short_window)::date,
         ((now() at time zone 'US/Mountain')::date - v_long_window)::date
  into v_end_date,v_short_start_date,v_long_start_date;

  select count(1)
  into v_short_window_exited_wip
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                    on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
         inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
  where (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date
--     and  flow.get_difference_of_dates_by_duration(
--     (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
--     (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false
    ;

  select count(1)
  into v_short_window_entered_wip
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                    on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
         inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
  where (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date
--     and  flow.get_difference_of_dates_by_duration(
--            (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
--            (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false
    ;

  select count(1)
  into v_long_window_exited_wip
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                    on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
         inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
  where (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date
--     and  flow.get_difference_of_dates_by_duration(
--            (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
--            (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false
    ;

  select count(1)
  into v_long_window_entered_wip
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                    on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
         inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
  where (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date
--     and  flow.get_difference_of_dates_by_duration(
--            (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
--            (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false
    ;


  select count(1)
  into v_short_window_exited
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                    on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
         inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
  where (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date
    and  flow.get_difference_of_dates_by_duration(
    (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
    (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 10
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false
  ;

  select count(1)
  into v_short_window_entered
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                    on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
         inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
  where (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_short_start_date and v_end_date
    and  flow.get_difference_of_dates_by_duration(
           (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
           (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 10
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false
  ;

  select count(1)
  into v_long_window_exited
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                    on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
         inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
  where (date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date
    and  flow.get_difference_of_dates_by_duration(
           (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
           (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 10
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false
  ;

  select count(1)
  into v_long_window_entered
  from flow.work_queue_cycle wqc2
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                    on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
         inner join flow.process_step_work_queue_type pswqt2 on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
  where (date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::date between v_long_start_date and v_end_date
    and  flow.get_difference_of_dates_by_duration(
           (wqc2.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
           (wqc2.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 10
    and pswqt2.work_queue_type_id = p_work_queue_type_id
    and pswqtpsst2.archived is false
    and pswqt2.archived is false
  ;

  select count(1) as short_window_numerator
  into v_short_window_numerator
  from flow.work_queue_cycle wqc
         inner join flow.company_process_step_status_type cpsst
                    on wqc.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
         inner join flow.process_step_status_type psst
                    on psst.id = cpsst.process_step_status_type_id and psst.archived is false
         inner join flow.project_process_step pps on pps.id = wqc.project_process_step_id and pps.archived is false
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                    on pswqtpsst.id = wqc.process_step_work_queue_type_process_step_status_type_id and
                       pswqtpsst.archived is false
         inner join flow.process_step_work_queue_type pswqt
                    on pswqtpsst.process_step_work_queue_type_id = pswqt.id and pswqt.archived is false
         inner join flow.process_step ps on ps.id = pswqt.process_step_id and ps.archived is false
         inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id and wqt.archived is false
         inner join flow.work_queue_category wqct on wqct.id = wqt.work_queue_category_id and wqct.archived is false
  where wqt.id = p_work_queue_type_id

    and case
          when wqc.date_exited_queue is not null then
                (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
                ((now() at time zone 'US/Mountain')::timestamp -
                 (short_window || ' ' || v_short_window_duration_type)::interval)::timestamp and
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

  select count(1) as short_window_denominator
  into v_short_window_denominator
  from flow.work_queue_cycle wqc
         inner join flow.company_process_step_status_type cpsst
                    on wqc.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
         inner join flow.process_step_status_type psst
                    on psst.id = cpsst.process_step_status_type_id and psst.archived is false
         inner join flow.project_process_step pps on pps.id = wqc.project_process_step_id and pps.archived is false
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                    on pswqtpsst.id = wqc.process_step_work_queue_type_process_step_status_type_id and
                       pswqtpsst.archived is false
         inner join flow.process_step_work_queue_type pswqt
                    on pswqtpsst.process_step_work_queue_type_id = pswqt.id and pswqt.archived is false
         inner join flow.process_step ps on ps.id = pswqt.process_step_id and ps.archived is false
         inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id and wqt.archived is false
         inner join flow.work_queue_category wqct on wqct.id = wqt.work_queue_category_id and wqct.archived is false
  where wqt.id = p_work_queue_type_id

    and case
          when wqc.date_exited_queue is not null then
              (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
              ((now() at time zone 'US/Mountain')::timestamp -
               (short_window || ' ' || v_short_window_duration_type)::interval)::timestamp and
            flow.get_difference_of_dates_by_duration(
                     (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                     (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
          else
            wqc.date_exited_queue is null
    end;


  select count(1) as long_window_numerator
  into v_long_window_numerator
  from flow.work_queue_cycle wqc
         inner join flow.company_process_step_status_type cpsst
                    on wqc.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
         inner join flow.process_step_status_type psst
                    on psst.id = cpsst.process_step_status_type_id and psst.archived is false
         inner join flow.project_process_step pps on pps.id = wqc.project_process_step_id and pps.archived is false
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                    on pswqtpsst.id = wqc.process_step_work_queue_type_process_step_status_type_id and
                       pswqtpsst.archived is false
         inner join flow.process_step_work_queue_type pswqt
                    on pswqtpsst.process_step_work_queue_type_id = pswqt.id and pswqt.archived is false
         inner join flow.process_step ps on ps.id = pswqt.process_step_id and ps.archived is false
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

  select count(1) as long_window_denominator
  into v_long_window_denominator
  from flow.work_queue_cycle wqc
         inner join flow.company_process_step_status_type cpsst
                    on wqc.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
         inner join flow.process_step_status_type psst
                    on psst.id = cpsst.process_step_status_type_id and psst.archived is false
         inner join flow.project_process_step pps on pps.id = wqc.project_process_step_id and pps.archived is false
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                    on pswqtpsst.id = wqc.process_step_work_queue_type_process_step_status_type_id and
                       pswqtpsst.archived is false
         inner join flow.process_step_work_queue_type pswqt
                    on pswqtpsst.process_step_work_queue_type_id = pswqt.id and pswqt.archived is false
         inner join flow.process_step ps on ps.id = pswqt.process_step_id and ps.archived is false
         inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id and wqt.archived is false
         inner join flow.work_queue_category wqct on wqct.id = wqt.work_queue_category_id and wqct.archived is false
  where wqt.id = p_work_queue_type_id

    and case
          when wqc.date_exited_queue is not null then
              (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp >=
              ((now() at time zone 'US/Mountain')::timestamp -
               (long_window || ' ' || v_long_window_duration_type)::interval)::timestamp and
              flow.get_difference_of_dates_by_duration(
                (wqc.date_exited_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp,
                (wqc.date_entered_queue at time zone 'UTC' at time zone 'US/Mountain')::timestamp, 4) > 0
          else
            wqc.date_exited_queue is null
    end;
  return query
    select v_short_window_numerator,
           v_short_window_denominator,
           v_long_window_numerator,
           v_long_window_denominator,
           case when v_short_window_numerator = 0 and v_short_window_denominator = 0 then
             1
            else
           round((v_short_window_numerator / case
                                               when v_short_window_denominator = 0 then 1
                                               else v_short_window_denominator::numeric end)::numeric, 2) end,
           case when v_long_window_numerator = 0 and v_long_window_denominator = 0 then
                  1
                else
           round((v_long_window_numerator /
                  case when v_long_window_denominator = 0 then 1 else v_long_window_denominator::numeric end)::numeric,
                 2)end,
           v_short_window_duration_type,
           v_long_window_duration_type,
           v_cycle_duration_type,
           v_expected_target,
           v_inverse_expectation,
           v_short_window_entered,
           v_short_window_exited,
           v_long_window_entered,
           v_long_window_exited,
           v_short_window_entered_wip - v_short_window_exited_wip,
           v_long_window_entered_wip - v_long_window_exited_wip;
END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
