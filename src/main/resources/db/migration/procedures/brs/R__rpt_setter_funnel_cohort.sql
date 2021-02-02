CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_cohort(p_custom_start_date date, p_custom_end_date date,
                                                        p_base_expectation numeric, p_user_ids integer[],
                                                        p_org_ids integer[])
    RETURNS SETOF json
    LANGUAGE plpgsql
AS
$function$
declare
    v_whole_company boolean;
    v_company_id integer;
BEGIN
    --doing this so it is easier to change to allow parameterizing later if needed
    select 3 into v_company_id;

    select -1 = any (p_user_ids) into v_whole_company;
    if v_whole_company then
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                     from (
                              --Appointments Created
                              with setter_funnel_3 as (
                                  select id,
                                         name,
                                         ratio,
                                         ratio * p_base_expectation                                                                                                         as expectation,
                                         display_order,
                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                (now() at time zone 'US/Mountain')::date)                                                                                   as today_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                (now() at time zone 'US/Mountain')::date - 1)                                                                               as yesterday_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                (now() at time zone 'US/Mountain')::date - 7
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                (now() at time zone 'US/Mountain')::date)                                                                                   as seven_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                (now() at time zone 'US/Mountain')::date - 14
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                (now() at time zone 'US/Mountain')::date - 7)                                                                               as prev_seven_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                (now() at time zone 'US/Mountain')::date - 30
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                (now() at time zone 'US/Mountain')::date)                                                                                   as thirty_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                (now() at time zone 'US/Mountain')::date - 60
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                (now() at time zone 'US/Mountain')::date - 30)                                                                              as prev_thirty_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date) as custom_date_range_count
                                  from brs.setter_funnel
                                  where id = 3
                              ),

                                   --Appointments Occurred
                                   setter_funnel_1 as (
                                       select id,
                                              name,
                                              ratio,
                                              ratio * p_base_expectation                       as expectation,
                                              display_order,
                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1 --do nothing, since pd.first_appointment only corresponds with appointments that don't have an outcome
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain')::date
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as today_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain')::date - 1
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as yesterday_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 7
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as seven_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 14
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date - 7
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as prev_seven_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 30
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as thirty_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 60
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date - 30
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as prev_thirty_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as custom_date_range_count
                                       from brs.setter_funnel
                                       where id = 1
                                   ),

                                   --Appointments Pitched
                                   setter_funnel_2 as (
                                       select id,
                                              name,
                                              ratio,
                                              ratio * p_base_expectation                                                                                                         as expectation,
                                              display_order,
                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain')::date)                                                                                   as today_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain')::date - 1)                                                                               as yesterday_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 7
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date)                                                                                   as seven_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 14
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date - 7)                                                                               as prev_seven_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 30
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date)                                                                                   as thirty_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 60
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date - 30)                                                                              as prev_thirty_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date) as custom_date_range_count
                                       from brs.setter_funnel
                                       where id = 2
                                   )

                              select id,
                                     name,
                                     ratio,
                                     expectation,
                                     display_order,
                                     today_day_count,
                                     yesterday_day_count,
                                     case
                                         when yesterday_day_count = 0 then 0
                                         else cast(cast(today_day_count - yesterday_day_count as numeric(10, 2)) /
                                                   yesterday_day_count as numeric(10, 2)) * 100
                                         end as today_percent,
                                     seven_day_count,
                                     prev_seven_day_count,
                                     case
                                         when prev_seven_day_count = 0 then 0
                                         else cast(cast(seven_day_count - prev_seven_day_count as numeric(10, 2)) /
                                                   prev_seven_day_count as numeric(10, 2)) * 100
                                         end as seven_percent,
                                     thirty_day_count,
                                     prev_thirty_day_count,
                                     case
                                         when prev_thirty_day_count = 0 then 0
                                         else cast(cast(thirty_day_count - prev_thirty_day_count as numeric(10, 2)) /
                                                   prev_thirty_day_count as numeric(10, 2)) * 100
                                         end as thirty_day_percent,
                                     custom_date_range_count
                              from (
                                       select *
                                       from setter_funnel_1
                                       union all
                                       select *
                                       from setter_funnel_2
                                       union all
                                       select *
                                       from setter_funnel_3
                                       union all
                                       select 4                  as id,
                                              'Pitch Percentage' as name,
                                              0                  as ratio,
                                              60                 as expectation,
                                              4                  as display_order,
                                              case
                                                  when (select today_day_count from setter_funnel_1 limit 1) = 0 then 0
                                                  else cast(cast(
                                                                        (select today_day_count from setter_funnel_2 limit 1) as numeric(10, 2)) /
                                                            cast(
                                                                        (select today_day_count from setter_funnel_1 limit 1) as numeric(10, 2)) as numeric(10, 2)) *
                                                       100
                                                  end            as today_day_count,
                                              null               as yesterday_day_count,
                                              case
                                                  when (select seven_day_count from setter_funnel_1 limit 1) = 0 then 0
                                                  else cast(cast(
                                                                        (select seven_day_count from setter_funnel_2 limit 1) as numeric(10, 2)) /
                                                            cast(
                                                                        (select seven_day_count from setter_funnel_1 limit 1) as numeric(10, 2)) as numeric(10, 2)) *
                                                       100
                                                  end            as seven_day_count,
                                              null               as prev_seven_day_count,
                                              case
                                                  when (select thirty_day_count from setter_funnel_1 limit 1) = 0 then 0
                                                  else cast(cast(
                                                                        (select thirty_day_count from setter_funnel_2 limit 1) as numeric(10, 2)) /
                                                            cast(
                                                                        (select thirty_day_count from setter_funnel_1 limit 1) as numeric(10, 2)) as numeric(10, 2)) *
                                                       100
                                                  end            as thirty_day_count,
                                              null               as prev_thirty_day_count,
                                              case
                                                  when (select custom_date_range_count from setter_funnel_1 limit 1) = 0
                                                      then 0
                                                  else cast(cast(
                                                                        (select custom_date_range_count from setter_funnel_2 limit 1) as numeric(10, 2)) /
                                                            cast(
                                                                        (select custom_date_range_count from setter_funnel_1 limit 1) as numeric(10, 2)) *
                                                            100 as numeric(10, 2))
                                                  end            as custom_date_range_count
                                   ) as row_counts
                              order by display_order
                          ) as funnel_rows;
    else
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                     from (
                              --Appointments Created
                              with setter_funnel_3 as (
                                  select id,
                                         name,
                                         ratio,
                                         ratio * p_base_expectation                                                                                       as expectation,
                                         display_order,
                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                (now() at time zone 'US/Mountain')::date
                                            and pd.setter_user_id = any (p_user_ids)
                                            and pd.setter_user_id = any
                                                (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                              p_org_ids,
                                                                              ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as today_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                (now() at time zone 'US/Mountain')::date - 1
                                            and pd.setter_user_id = any (p_user_ids)
                                            and pd.setter_user_id = any
                                                (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                              p_org_ids,
                                                                              ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as yesterday_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                (now() at time zone 'US/Mountain')::date - 7
                                            and pd.setter_user_id = any (p_user_ids)
                                            and pd.setter_user_id = any
                                                (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                              p_org_ids,
                                                                              ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as seven_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                (now() at time zone 'US/Mountain')::date - 14
                                            and pd.setter_user_id = any (p_user_ids)
                                            and pd.setter_user_id = any
                                                (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                              p_org_ids,
                                                                              ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_seven_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                (now() at time zone 'US/Mountain')::date - 30
                                            and pd.setter_user_id = any (p_user_ids)
                                            and pd.setter_user_id = any
                                                (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                              p_org_ids,
                                                                              ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as thirty_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                (now() at time zone 'US/Mountain')::date - 60
                                            and pd.setter_user_id = any (p_user_ids)
                                            and pd.setter_user_id = any
                                                (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                              p_org_ids,
                                                                              ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_thirty_day_count,

                                         (select count(1)
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.user_position up
                                                              on (up.user_id = pd.setter_user_id and
                                                                  up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                          where pd.source = 525 --Setter Gen
                                            and (pd.first_appointment_pitched is not null
                                                or pd.first_appointment_missed is not null
                                                or pd.first_appointment_not_pitched_or_missed is not null
                                                or pd.first_appointment is not null
                                                or pd.closer_appointment_start is not null)
                                            and pd.company_id = v_company_id
                                            and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                            and pd.setter_user_id = any (p_user_ids)
                                            and pd.setter_user_id = any
                                                (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                              p_org_ids,
                                                                              ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as custom_date_range_count
                                  from brs.setter_funnel
                                  where id = 3
                              ),

                                   --Appointments Occurred
                                   setter_funnel_1 as (
                                       select id,
                                              name,
                                              ratio,
                                              ratio * p_base_expectation                                                                                       as expectation,
                                              display_order,
                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1 --do nothing, since pd.first_appointment only corresponds with appointments that don't have an outcome
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain')::date
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as today_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1 --do nothing, since pd.first_appointment only corresponds with appointments that don't have an outcome
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain')::date - 1
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as yesterday_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 7
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as seven_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 14
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date - 7
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_seven_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 30
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as thirty_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 60
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date - 30
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_thirty_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                      --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                               then pd.first_appointment_pitched_id != 4 --Cancelled
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is not null
                                                               then pd.first_appointment_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is not null
                                                               then pd.first_appointment_not_pitched_or_missed_id != 4
                                                           when pd.first_appointment_pitched is null
                                                               and pd.first_appointment_missed is null
                                                               and pd.first_appointment_not_pitched_or_missed is null
                                                               and pd.first_appointment is not null
                                                               then 1=1
                                                           else (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4)
                                                           end)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.first_appointment_not_pitched_or_missed is not null
                                                     or pd.first_appointment is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and (((case when pd.first_appointment_pitched is not null
                                                     then pd.first_appointment_pitched
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is not null
                                                     then pd.first_appointment_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is not null
                                                     then pd.first_appointment_not_pitched_or_missed
                                                 when pd.first_appointment_pitched is null
                                                     and pd.first_appointment_missed is null
                                                     and pd.first_appointment_not_pitched_or_missed is null
                                                     and pd.first_appointment is not null
                                                     then pd.first_appointment
                                                 else pd.closer_appointment_start
                                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as custom_date_range_count
                                       from brs.setter_funnel
                                       where id = 1
                                   ),

                                   --Appointments Pitched
                                   setter_funnel_2 as (
                                       select id,
                                              name,
                                              ratio,
                                              ratio * p_base_expectation                                                                                       as expectation,
                                              display_order,
                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as today_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                                     (now() at time zone 'US/Mountain')::date - 1
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as yesterday_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 7
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as seven_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 14
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date - 7
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_seven_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 30
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as thirty_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >=
                                                     (now() at time zone 'US/Mountain')::date - 60
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <=
                                                     (now() at time zone 'US/Mountain')::date - 30
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_thirty_day_count,

                                              (select count(1)
                                               from brs.project_details pd
                                                        inner join flow.project p on p.id = pd.project_id
                                                        inner join flow.user_position up
                                                                   on (up.user_id = pd.setter_user_id and
                                                                       up.primary_flag is true and up.position_id in (4,5) and up.archived is not true)
                                               where pd.source = 525                                     --Setter Gen
                                                 and (case when pd.first_appointment_pitched is not null
                                                          then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                                      when pd.first_appointment_pitched is null
                                                          and pd.first_appointment_missed is not null
                                                          then pd.first_appointment_missed_id in (2,3,1139,1140)
                                                      else pd.closer_appointment_outcome in (2,3,1139,1140)
                                                      end)
                                                 and (pd.first_appointment_pitched is not null
                                                     or pd.first_appointment_missed is not null
                                                     or pd.closer_appointment_start is not null)
                                                 and pd.company_id = v_company_id
                                                 and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                                 and pd.setter_user_id = any (p_user_ids)
                                                 and pd.setter_user_id = any
                                                     (brs.limit_by_org_for_setters(Array [pd.setter_user_id]::integer[],
                                                                                   p_org_ids,
                                                                                   ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as custom_date_range_count
                                       from brs.setter_funnel
                                       where id = 2
                                   )

                              select id,
                                     name,
                                     ratio,
                                     expectation,
                                     display_order,
                                     today_day_count,
                                     yesterday_day_count,
                                     case
                                         when yesterday_day_count = 0 then 0
                                         else cast(cast(today_day_count - yesterday_day_count as numeric(10, 2)) /
                                                   yesterday_day_count as numeric(10, 2)) * 100
                                         end as today_percent,
                                     seven_day_count,
                                     prev_seven_day_count,
                                     case
                                         when prev_seven_day_count = 0 then 0
                                         else cast(cast(seven_day_count - prev_seven_day_count as numeric(10, 2)) /
                                                   prev_seven_day_count as numeric(10, 2)) * 100
                                         end as seven_percent,
                                     thirty_day_count,
                                     prev_thirty_day_count,
                                     case
                                         when prev_thirty_day_count = 0 then 0
                                         else cast(cast(thirty_day_count - prev_thirty_day_count as numeric(10, 2)) /
                                                   prev_thirty_day_count as numeric(10, 2)) * 100
                                         end as thirty_day_percent,
                                     custom_date_range_count
                              from (select *
                                    from setter_funnel_1
                                    union all
                                    select *
                                    from setter_funnel_2
                                    union all
                                    select *
                                    from setter_funnel_3
                                    union all
                                    select 4                  as id,
                                           'Pitch Percentage' as name,
                                           0                  as ratio,
                                           60                 as expectation,
                                           4                  as display_order,
                                           case
                                               when (select today_day_count from setter_funnel_1 limit 1) = 0 then 0
                                               else cast(cast(
                                                                     (select today_day_count from setter_funnel_2 limit 1) as numeric(10, 2)) /
                                                         cast(
                                                                     (select today_day_count from setter_funnel_1 limit 1) as numeric(10, 2)) as numeric(10, 2)) *
                                                    100
                                               end            as today_day_count,
                                           null                  yesterday_count,
                                           case
                                               when (select seven_day_count from setter_funnel_1 limit 1) = 0 then 0
                                               else cast(cast(
                                                                     (select seven_day_count from setter_funnel_2 limit 1) as numeric(10, 2)) /
                                                         cast(
                                                                     (select seven_day_count from setter_funnel_1 limit 1) as numeric(10, 2)) as numeric(10, 2)) *
                                                    100
                                               end            as seven_day_count,
                                           null                  prev_seven_day_count,
                                           case
                                               when (select thirty_day_count from setter_funnel_1 limit 1) = 0 then 0
                                               else cast(cast(
                                                                     (select thirty_day_count from setter_funnel_2 limit 1) as numeric(10, 2)) /
                                                         cast(
                                                                     (select thirty_day_count from setter_funnel_1 limit 1) as numeric(10, 2)) as numeric(10, 2)) *
                                                    100
                                               end            as thirty_day_count,
                                           null                  prev_thirty_day_count,
                                           case
                                               when (select custom_date_range_count from setter_funnel_1 limit 1) = 0
                                                   then 0
                                               else cast(cast(
                                                                     (select custom_date_range_count from setter_funnel_2 limit 1) as numeric(10, 2)) /
                                                         cast(
                                                                     (select custom_date_range_count from setter_funnel_1 limit 1) as numeric(10, 2)) *
                                                         100 as numeric(10, 2))
                                               end            as custom_date_range_count
                                   ) as row_counts
                              order by display_order
                          ) as funnel_rows;

    end if;

END
$function$
