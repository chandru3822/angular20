-- drop function if exists brs.get_days_to_credit_expiration(p_project_id bigint, p_pps_id bigint);
CREATE OR REPLACE FUNCTION brs.get_days_to_credit_expiration(p_project_id bigint, p_pps_id bigint)
  returns int AS
$BODY$
declare
  v_days_to_expiration                int = 0;
  v_new_credit_expiration_date        date;
  v_original_credit_expiration_date   date;
  v_credit_decision_date_from_booking date;
  v_today_in_timezone                 date;
BEGIN

  select (now() at time zone coalesce(project_time_zone, 'US/Mountain'))::date
  into v_today_in_timezone
  from brs.project_details pd
  where project_id = p_project_id;

  select date_value
  into v_new_credit_expiration_date
  from flow.project_process_step_custom_field_value ppscfv
  where ppscfv.custom_field_group_assignment_id = 21194 --new credit expiration date on credit status
    and ppscfv.project_process_step_id = p_pps_id;

  select date_value
  into v_original_credit_expiration_date
  from flow.project_process_step_custom_field_value ppscfv
  where ppscfv.custom_field_group_assignment_id = 24134 --original credit expiration date on Credit Status
    and ppscfv.project_process_step_id = p_pps_id;

  if (v_new_credit_expiration_date is not null or v_original_credit_expiration_date is not null) then
    --take the dates in this order and subtract today's date.
    select ((coalesce(v_new_credit_expiration_date, v_original_credit_expiration_date)::date) - v_today_in_timezone)::int
    into v_days_to_expiration;
  else
    select date_value
    into v_credit_decision_date_from_booking
    from flow.project_process_step_custom_field_value ppscfv
    where ppscfv.custom_field_group_assignment_id = 62 --credit decision date on booking (main)
      and ppscfv.project_process_step_id = (select pps.id
                                            from flow.project_process_step pps
                                            where pps.process_step_id = 4 --booking
                                              and pps.main is true
                                              and pps.project_id = (select pps1.project_id
                                                                    from flow.project_process_step pps1
                                                                    where pps1.id = p_pps_id));

    select case
             when v_credit_decision_date_from_booking is not null then
                 ((v_credit_decision_date_from_booking + interval '180 days')::date - v_today_in_timezone)::int
             else 0 end
    into v_days_to_expiration;
  end if;

  return case when v_days_to_expiration < 0 then 0 else v_days_to_expiration end;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
