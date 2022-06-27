CREATE OR REPLACE FUNCTION brs.update_appointment_data(p_project_process_step_event_id integer, p_project_id integer,p_start_time timestamp default null)
  RETURNS void AS
$BODY$
declare
  v_missed_id                                   integer;
  v_missed                                      timestamp;
  v_pitched_id                                  integer;
  v_pitched                                     timestamp;
  v_not_either_id                               integer;
  v_not_either                                  timestamp;
  v_pitched_ppse_id                             integer;
  v_missed_ppse_id                              integer;
  v_not_pitched_missed_ppse_id                  integer;
  v_first_appointment_id                        integer;
  v_first_appointment_id_ppse_id                integer;
  v_first_appointment_start_time                timestamp;
  v_first_appointment_id_not_used               integer;
  v_first_appointment_start_time_not_used       timestamp;
  v_first_appointment_ppse_id                   integer;
  v_count                                       integer;
  v_prioritized_closer_appointment_outcome      integer;
  v_prioritized_closer_appointment_outcome_date timestamp;

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
      prioritized_closer_appointment_outcome_date     = null
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


  v_prioritized_closer_appointment_outcome = coalesce(v_pitched_id, v_missed_id, v_not_either_id);
  v_prioritized_closer_appointment_outcome_date = coalesce(v_pitched, v_missed, v_not_either);

raise notice '12222222 %',v_first_appointment_start_time;
  raise notice '55555555 %',v_first_appointment_ppse_id;
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
      first_appointment_id                            = v_first_appointment_id,
      first_appointment_id_ppse_id                    = v_first_appointment_id_ppse_id,
      first_appointment                               = v_first_appointment_start_time,
      first_appointment_ppse_id                       = v_first_appointment_ppse_id,
      prioritized_closer_appointment_outcome          = v_prioritized_closer_appointment_outcome,
      prioritized_closer_appointment_outcome_date     = v_prioritized_closer_appointment_outcome_date
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

