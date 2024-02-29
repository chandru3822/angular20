drop function if exists brs.update_appointment_data(p_project_process_step_event_id bigint, p_project_id bigint,p_start_time timestamp);
drop function if exists brs.update_appointment_data(p_project_process_step_event_id bigint, p_project_id bigint,p_start_time timestamp,p_came_from_ppse boolean);
CREATE OR REPLACE FUNCTION brs.update_appointment_data(p_project_process_step_event_id bigint, p_project_id bigint,p_start_time timestamp default null,p_came_from_ppse boolean  default false)
  RETURNS void AS
$BODY$
declare
  v_missed_id                                   bigint;
  v_missed                                      timestamp;
  v_pitched_id                                  bigint;
  v_pitched                                     timestamp;
  v_not_either_id                               bigint;
  v_not_either                                  timestamp;
  v_pitched_ppse_id                             bigint;
  v_missed_ppse_id                              bigint;
  v_not_pitched_missed_ppse_id                  bigint;
  v_first_appointment_id                        bigint;
  v_first_appointment_id_ppse_id                bigint;
  v_first_appointment_start_time                timestamp;
  v_first_appointment_id_not_used               bigint;
  v_first_appointment_start_time_not_used       timestamp;
  v_first_appointment_ppse_id                   bigint;
  v_count                                       bigint;
  v_prioritized_closer_appointment_outcome      bigint;
  v_prioritized_closer_appointment_outcome_date timestamp;
  v_prioritized_closer_dashboard_outcome_id     bigint;
  v_prioritized_closer_dashboard_outcome        text;
  v_prioritized_closer_dashboard_start_time     timestamp;
  v_prioritized_closer_dashboard_checkin        timestamp;
  v_prioritized_closer_dashboard_ppse_id        bigint;
BEGIN
  update brs.project_details
  set first_appointment_not_pitched_or_missed         = null,
      first_appointment_not_pitched_or_missed_id      = null,
      first_appointment_not_pitched_or_missed_ppse_id = null,
      first_appointment_missed                        = null,
      first_appointment_missed_id                     = null,
      first_appointment_missed_ppse_id                = null,
      first_appointment_pitched                       = null,
      first_appointment_pitched_id                    = null,
      first_appointment_pitched_ppse_id               = null,
      setter_milestone_pay                            = null,
      first_appointment_id                            = null,
      first_appointment_id_ppse_id                    = null,
      first_appointment                               = null,
      first_appointment_ppse_id                       = null,
      prioritized_closer_appointment_outcome          = null,
      prioritized_closer_appointment_outcome_date     = null,
      prioritized_closer_dashboard_outcome_id         = null,
      prioritized_closer_dashboard_outcome            = null,
      prioritized_closer_dashboard_start_time         = null,
      prioritized_closer_dashboard_checkin            = null,
      prioritized_closer_dashboard_ppse_id            = null
  where project_id = p_project_id;

  select int_value, coalesce(start_time,p_start_time), id
  into v_first_appointment_id_not_used,v_first_appointment_start_time,v_first_appointment_ppse_id
  from brs.get_earliest_outcome_record_by_type(p_project_process_step_event_id, null, false);

  select count(1)
  into v_count
  from flow.project_process_step_event ppse
         inner join flow.project_process_step_event_custom_field_value ppsecfv2
                    on ppse.id = ppsecfv2.project_process_step_event_id
                      and ppsecfv2.custom_field_group_assignment_id = 4
  where ppse.id = v_first_appointment_ppse_id;


  select int_value, start_time, id
  into v_pitched_id,v_pitched,v_pitched_ppse_id
  from brs.get_earliest_outcome_record_by_type(p_project_process_step_event_id, 'OUTCOME_PITCHED');

  select int_value, start_time, id
  into v_missed_id,v_missed,v_missed_ppse_id
  from brs.get_earliest_outcome_record_by_type(p_project_process_step_event_id, 'OUTCOME_MISSED');

  select int_value, start_time, id
  into v_not_either_id,v_not_either,v_not_pitched_missed_ppse_id
  from brs.get_earliest_outcome_record_by_type(p_project_process_step_event_id, 'OUTCOME_NOT_PITCHED_MISSED');

  if v_count > 0 then
    select int_value, start_time, id
    into v_first_appointment_id,v_first_appointment_start_time_not_used,v_first_appointment_id_ppse_id
    from brs.get_earliest_outcome_record_by_type(p_project_process_step_event_id, null);
  end if;

  select distinct on (pps.project_id)
    ppsecfv1.int_value,
    (select lov.name from flow.list_of_value lov where lov.id = ppsecfv1.int_value),
    ppse.start_time,
    ppsecfv.timestamp_value,
    ppse.id
  into v_prioritized_closer_dashboard_outcome_id,
    v_prioritized_closer_dashboard_outcome,
    v_prioritized_closer_dashboard_start_time,
    v_prioritized_closer_dashboard_checkin,
    v_prioritized_closer_dashboard_ppse_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps
                    on pps.id = ppse.project_process_step_id and pps.process_step_id in (1, 3390)
         left join flow.project_process_step_event_custom_field_value ppsecfv
                   on ppsecfv.project_process_step_event_id = ppse.id and
                      ppsecfv.custom_field_group_assignment_id = 1377
         left join flow.project_process_step_event_custom_field_value ppsecfv1
                   on ppsecfv1.project_process_step_event_id = ppse.id and ppsecfv1.custom_field_group_assignment_id = 4
  where pps.project_id = p_project_id
    and ppsecfv1.int_value = any ('{2,1139,1140}')
    and ppse.start_time is not null
    and ppse.resource_id is not null
  order by project_id, start_time desc;

  if v_prioritized_closer_dashboard_ppse_id is null then
    select distinct on (pps.project_id)
      ppsecfv1.int_value,
      (select lov.name from flow.list_of_value lov where lov.id = ppsecfv1.int_value),
      ppse.start_time,
      ppsecfv.timestamp_value,
      ppse.id
    into v_prioritized_closer_dashboard_outcome_id,
      v_prioritized_closer_dashboard_outcome,
      v_prioritized_closer_dashboard_start_time,
      v_prioritized_closer_dashboard_checkin,
      v_prioritized_closer_dashboard_ppse_id
    from flow.project_process_step_event ppse
           inner join flow.project_process_step pps
                      on pps.id = ppse.project_process_step_id and pps.process_step_id in (1, 3390)
           left join flow.project_process_step_event_custom_field_value ppsecfv
                     on ppsecfv.project_process_step_event_id = ppse.id and
                        ppsecfv.custom_field_group_assignment_id = 1377
           left join flow.project_process_step_event_custom_field_value ppsecfv1
                     on ppsecfv1.project_process_step_event_id = ppse.id and ppsecfv1.custom_field_group_assignment_id = 4
    where pps.project_id = p_project_id
      and ppse.start_time is not null
      and ppse.resource_id is not null
    order by project_id, start_time desc;

    if p_came_from_ppse is true and p_start_time > v_prioritized_closer_dashboard_start_time then
      v_prioritized_closer_dashboard_start_time = p_start_time;
      v_prioritized_closer_dashboard_ppse_id = p_project_process_step_event_id;
      v_prioritized_closer_dashboard_checkin = null;
      v_prioritized_closer_dashboard_outcome_id = null;
      v_prioritized_closer_dashboard_outcome = null;
    end if;
  end if;


  v_prioritized_closer_appointment_outcome = coalesce(v_pitched_id, v_missed_id, v_not_either_id);
  v_prioritized_closer_appointment_outcome_date = coalesce(v_pitched, v_missed, v_not_either);

  update brs.project_details
  set first_appointment_missed_id                     = v_missed_id,
      first_appointment_missed                        = v_missed,
      first_appointment_missed_ppse_id                = v_missed_ppse_id,
      first_appointment_pitched_id                    = v_pitched_id,
      first_appointment_pitched                       = v_pitched,
      first_appointment_pitched_ppse_id               = v_pitched_ppse_id,
      first_appointment_not_pitched_or_missed_id      = v_not_either_id,
      first_appointment_not_pitched_or_missed         = v_not_either,
      first_appointment_not_pitched_or_missed_ppse_id = v_not_pitched_missed_ppse_id,
      first_appointment_id                            = v_first_appointment_id,  --this is the first outcome id
      first_appointment_id_ppse_id                    = v_first_appointment_id_ppse_id,  --this is the first ppse id for the outcome
      first_appointment                               = v_first_appointment_start_time,
      first_appointment_ppse_id                       = v_first_appointment_ppse_id,
      prioritized_closer_appointment_outcome          = v_prioritized_closer_appointment_outcome,
      prioritized_closer_appointment_outcome_date     = v_prioritized_closer_appointment_outcome_date,
      prioritized_closer_dashboard_outcome_id         = v_prioritized_closer_dashboard_outcome_id,
      prioritized_closer_dashboard_outcome            = v_prioritized_closer_dashboard_outcome,
      prioritized_closer_dashboard_start_time         = v_prioritized_closer_dashboard_start_time,
      prioritized_closer_dashboard_checkin            = v_prioritized_closer_dashboard_checkin,
      prioritized_closer_dashboard_ppse_id            = v_prioritized_closer_dashboard_ppse_id
  where project_id = p_project_id;

  if v_missed_id is not null or v_pitched_id is not null then
    update brs.project_details
    set setter_milestone_pay = coalesce(least(v_missed, v_pitched), now())
    where project_id = p_project_id;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

