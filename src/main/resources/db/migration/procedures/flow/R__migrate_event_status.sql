drop function if exists flow.migrate_event_status(integer, integer, timestamp, timestamp, integer, integer, integer,
                                                  integer);
CREATE OR REPLACE function flow.migrate_event_status(p_project_process_step_id integer,
                                                     p_project_id integer,
                                                     p_start_time timestamp,
                                                     p_end_time timestamp,
                                                     p_child1 integer,
                                                     p_child2 integer default 0,
                                                     p_child3 integer default 0,
                                                     p_child4 integer default 0)
  returns table
          (
            process_event_status_id integer,
            cancel_timestamp        timestamp,
            complete_timestamp      timestamp,
            scheduled_timestamp     timestamp
          )
as
$$
declare
  v_company_event_status_type_id_pending  integer;
  v_company_event_status_type_id_complete integer;
  v_company_event_status_type_id_NV       integer;
  v_company_event_status_type_id_C        integer;
  v_company_event_status_type_id_NCO      integer;
  v_company_event_status_type_id_RTS      integer;
  v_company_status_id1                    integer;
  v_company_status_id2                    integer;
  v_company_status_id3                    integer;
  v_company_status_id4                    integer;
  v_process_event_status_id               integer;
  pps_id_2                                integer;
  pps_id_3                                integer;
  v_cancel_timestamp                      timestamp;
  v_return_cancel_timestamp               timestamp;
  v_return_complete_timestamp             timestamp;
  v_complete_timestamp1                   timestamp;
  v_complete_timestamp2                   timestamp;
  v_complete_timestamp3                   timestamp;
  v_complete_timestamp4                   timestamp;
  v_process_step_id                       integer;
  v_online_timestamp_value                timestamp;
  v_main                                  boolean;
BEGIN
  v_online_timestamp_value = null;
  select process_step_id
  into v_process_step_id
  from flow.project_process_step
  where id = p_project_process_step_id;

  if v_process_step_id in (13, 3099, 3395) then
    select timestamp_value
    into v_online_timestamp_value
    from flow.project_process_step_custom_field_value
    where project_process_step_id = p_project_process_step_id
      and custom_field_group_assignment_id in (20917, 19108, 19201)
    limit 1;

  end if;


  select id
  into v_company_event_status_type_id_pending
  from flow.company_event_status_type
  where event_status_type = 'Pending';
  select id
  into v_company_event_status_type_id_complete
  from flow.company_event_status_type
  where event_status_type = 'Complete';
  select id
  into v_company_event_status_type_id_NV
  from flow.company_event_status_type
  where event_status_type = 'Ready to Verify';
  select id
  into v_company_event_status_type_id_C
  from flow.company_event_status_type
  where event_status_type = 'Cancelled';
  select id
  into v_company_event_status_type_id_RTS
  from flow.company_event_status_type
  where event_status_type = 'Ready to Schedule';
  select id
  into v_company_event_status_type_id_NCO
  from flow.company_event_status_type
  where event_status_type = 'Not Complete - Other';


  select psst.id,
         coalesce(pps.cancelled_date, pps.date_modified),
         coalesce(pps.process_step_complete_date, pps.date_modified),
         pps.main
  into v_company_status_id1,v_cancel_timestamp,v_complete_timestamp1,v_main
  from flow.project_process_step pps
         inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
         inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
  where pps.id = p_project_process_step_id
    and pps.process_step_id = p_child1;

  if p_child2 is not null and p_child2 != 0 then
    select psst.id, pps.id, coalesce(pps.process_step_complete_date, pps.date_modified)
    into v_company_status_id2,pps_id_2,v_complete_timestamp2
    from flow.project_process_step pps
           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
           inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where pps.project_id = p_project_id
      and pps.process_step_id = p_child2
      and pps.parent_project_process_step_id = p_project_process_step_id;
  end if;

  if p_child3 is not null and p_child3 != 0 and pps_id_2 is not null then
    select psst.id, pps.id, coalesce(pps.process_step_complete_date, pps.date_modified)
    into v_company_status_id3,pps_id_3,v_complete_timestamp3
    from flow.project_process_step pps
           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
           inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where pps.project_id = p_project_id
      and pps.process_step_id = p_child3
      and pps.parent_project_process_step_id = pps_id_2;
  end if;

  if p_child3 is not null and p_child3 != 0 and p_child1 = 168 and v_company_status_id3 is null then
    select psst.id, pps.id, coalesce(pps.process_step_complete_date, pps.date_modified)
    into v_company_status_id3,pps_id_3,v_complete_timestamp3
    from flow.project_process_step pps
           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
           inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where pps.project_id = p_project_id
      and pps.process_step_id = p_child3
      and pps.parent_project_process_step_id = p_project_process_step_id;
  end if;

  if p_child4 is not null and p_child4 != 0 and pps_id_3 is not null then
    select psst.id, coalesce(pps.process_step_complete_date, pps.date_modified)
    into v_company_status_id4,v_complete_timestamp4
    from flow.project_process_step pps
           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
           inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where pps.project_id = p_project_id
      and pps.process_step_id = p_child4
      and pps.parent_project_process_step_id = pps_id_3;
  end if;


  if v_online_timestamp_value is not null and v_online_timestamp_value < now() then
    v_process_event_status_id = v_company_event_status_type_id_complete;
    v_return_complete_timestamp =
      least(v_complete_timestamp1, v_complete_timestamp2, v_complete_timestamp3, v_complete_timestamp4);
  elsif v_online_timestamp_value is not null and v_online_timestamp_value > now() then
    v_process_event_status_id = v_company_event_status_type_id_pending;
  elsif v_company_status_id1 = 1 then
    if p_start_time > now() or now() between p_start_time and p_end_time then
      v_process_event_status_id = v_company_event_status_type_id_pending;
    elsif ((p_end_time < now()) or (p_start_time < now() and p_end_time is null)) then
      v_process_event_status_id = v_company_event_status_type_id_NV;
    end if;
  elsif v_company_status_id1 = 2 and v_main is true then
    if (v_company_status_id2 is not null and v_company_status_id2 = 1) or
       (v_company_status_id3 is not null and v_company_status_id3 = 1) or
       (v_company_status_id4 is not null and v_company_status_id4 = 1) then
      if p_start_time > now() or now() between p_start_time and p_end_time then
        v_process_event_status_id = v_company_event_status_type_id_pending;
        update flow.project_process_step
        set company_process_step_status_type_id = 76
        where id = p_project_process_step_id;
      else
        v_process_event_status_id = v_company_event_status_type_id_NV;
        update flow.project_process_step
        set company_process_step_status_type_id = 76
        where id = p_project_process_step_id;
      end if;
    elsif (v_company_status_id2 is not null and v_company_status_id2 = 3) or
          (v_company_status_id3 is not null and v_company_status_id3 = 3) or
          (v_company_status_id4 is not null and v_company_status_id4 = 3) then
      v_process_event_status_id = v_company_event_status_type_id_NCO;
      v_return_cancel_timestamp = v_cancel_timestamp;
    else
      v_process_event_status_id = v_company_event_status_type_id_complete;
      v_return_complete_timestamp =
        greatest(v_complete_timestamp1, v_complete_timestamp2, v_complete_timestamp3, v_complete_timestamp4);
    end if;
  elsif v_company_status_id1 = 2 and v_main is false then
    if (v_company_status_id2 is not null and v_company_status_id2 = 3) or
       (v_company_status_id3 is not null and v_company_status_id3 = 3) or
       (v_company_status_id4 is not null and v_company_status_id4 = 3) then
      v_process_event_status_id = v_company_event_status_type_id_c;
      v_return_cancel_timestamp = v_cancel_timestamp;
    elsif
        (v_company_status_id2 is null or (v_company_status_id2 is not null and v_company_status_id2 = 2)) and
        (v_company_status_id3 is null or (v_company_status_id3 is not null and v_company_status_id3 = 2)) and
        (v_company_status_id4 is null or (v_company_status_id4 is not null and v_company_status_id4 = 2)) then
      v_process_event_status_id = v_company_event_status_type_id_complete;
      v_return_complete_timestamp =
        greatest(v_complete_timestamp1, v_complete_timestamp2, v_complete_timestamp3, v_complete_timestamp4);
    else
      v_process_event_status_id = v_company_event_status_type_id_pending;
    end if;
  else
    v_process_event_status_id = v_company_event_status_type_id_nco;
    v_return_cancel_timestamp = v_cancel_timestamp;
  end if;

  return query select v_process_event_status_id,
                      v_return_cancel_timestamp,
                      v_return_complete_timestamp,
                      v_complete_timestamp1;

end

$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


