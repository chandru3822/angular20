CREATE OR REPLACE function flow.migrate_event_status(p_project_process_step_id integer, p_project_id integer,
                                                     p_start_time timestamp,
                                                     p_end_time timestamp,
                                                     p_child1 integer, p_child2 integer default 0,
                                                     p_child3 integer default 0,
                                                     p_child4 integer default 0)
  returns integer as
$$
declare
  v_company_event_status_type_id_pending   integer;
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
BEGIN
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
  where event_status_type = 'Needs Verification';
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


  select psst.id
  into v_company_status_id1
  from flow.project_process_step pps
         inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
         inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
  where pps.id = p_project_process_step_id
    and pps.process_step_id = p_child1;

  if p_child2 is not null and p_child2 != 0 then
    select psst.id, pps.id
    into v_company_status_id2,pps_id_2
    from flow.project_process_step pps
           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
           inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where pps.project_id = p_project_id
      and pps.process_step_id = p_child2
      and pps.parent_project_process_step_id = p_project_process_step_id;
  end if;

  if p_child3 is not null and p_child3 != 0 and pps_id_2 is not null then
    select psst.id, pps.id
    into v_company_status_id3,pps_id_3
    from flow.project_process_step pps
           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
           inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where pps.project_id = p_project_id
      and pps.process_step_id = p_child3
      and pps.parent_project_process_step_id = pps_id_2;
  end if;

  if p_child4 is not null and p_child4 != 0 and pps_id_3 is not null then
    select psst.id
    into v_company_status_id4
    from flow.project_process_step pps
           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
           inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where pps.project_id = p_project_id
      and pps.process_step_id = p_child4
      and pps.parent_project_process_step_id = pps_id_3;
  end if;


--   raise notice 'second child=%',v_company_status_id2;
--   raise notice 'third child=%',v_company_status_id3;
--   raise notice 'fourth child=%',v_company_status_id4;

  if p_start_time is null and p_end_time is null and v_company_status_id1 = 3 then
    v_process_event_status_id = v_company_event_status_type_id_NCO;
  elsif p_start_time is null and p_end_time is null then
    v_process_event_status_id = v_company_event_status_type_id_RTS;
  elsif p_start_time > now() then
    v_process_event_status_id = v_company_event_status_type_id_pending;
  elsif p_start_time is not null and p_end_time is not null and (p_end_time < now() or now() between p_start_time and p_end_time)  then
    if v_company_status_id1 = 1 or (v_company_status_id2 is not null and v_company_status_id2 = 1) or
       (v_company_status_id3 is not null and v_company_status_id3 = 1) or
       (v_company_status_id4 is not null and v_company_status_id4 = 1) then
      v_process_event_status_id = v_company_event_status_type_id_NV;
    else
      v_process_event_status_id = v_company_event_status_type_id_complete;
    end if;
  end if;
  return v_process_event_status_id;

end

$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

