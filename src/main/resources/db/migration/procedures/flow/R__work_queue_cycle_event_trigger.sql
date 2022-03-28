CREATE OR REPLACE FUNCTION flow.create_event_work_queue_cycle()
  RETURNS TRIGGER AS
$$
declare
  v_new_work_queue_type_id          integer;
  v_psewqtest_id                    integer;
  v_old                             record;
  v_work_type_ids                   integer[];
  v_event_status_type_id            integer;
  v_process_step_status_type_id     integer;
  v_company_process_step_status_type_id integer;
  v_company_project_status_type_id  integer;
  v_project_status_type_id          integer;
BEGIN

  select cpst.id as company_project_status_type_id, cpst.project_status_type_id as project_status_type_id,
         cpsst2.id,cpsst2.process_step_status_type_id
  into v_company_project_status_type_id,v_project_status_type_id,
    v_company_process_step_status_type_id,v_process_step_status_type_id
  from flow.project_process_step pps
       inner join flow.project p on pps.project_id = p.id
         inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
       inner join flow.company_process_step_status_type cpsst2 on pps.company_process_step_status_type_id = cpsst2.id
  where pps.id = new.project_process_step_id;

  select event_status_type_id
  into v_event_status_type_id
  from flow.company_event_status_type
  where id = new.company_event_status_type_id;


  /*This query looks at the new status type and determines if the new status is part of a work queue.
    If it is part of a work queue we keep processing, otherwise we set the exit date if there is currently
    a row in the work_queue_cycle table and we do this in the update section*/
  IF (TG_OP = 'UPDATE') and old.start_time is null and new.start_time is not null THEN
    insert into flow.work_queue_cycle(project_process_step_event_id, company_event_status_type_id,
                                      process_step_event_work_queue_type_event_status_type_id,
                                      date_entered_queue,
                                      created_by_id)
      (select new.id, new.company_event_status_type_id, event.process_step_event_work_queue_type_event_status_type_id, now(), new.created_by_id
         from flow.get_event_work_queue_type_configs(new.process_step_event_id) event
       where
         ((new.company_event_status_type_id = event.company_event_status_type_id or
           v_event_status_type_id = event.event_status_type_id) and
           (v_company_process_step_status_type_id = event.company_process_status_type_id or
           v_process_step_status_type_id = event.process_step_status_type_id) and
          (v_company_project_status_type_id = event.company_project_status_type_id or
           v_project_status_type_id = event.project_status_type_id)));

    /*We only update if the statuses change*/
  elsif (TG_OP = 'UPDATE') and (old.company_event_status_type_id is not null and old.company_event_status_type_id != new.company_event_status_type_id) THEN
    /*looping through all work_queue_cycle records where the old status matches and the project_process_step_id matches.
      Inside the loop we are querying to see if any of the old record work_queue_type_id's match what we would be
      inserting based on what the new status work_queue_type_id.  */
    for v_old in select psewqtest.process_step_event_work_queue_type_id, wqc.id
                 from flow.process_step_event_work_queue_type_event_status_type psewqtest
                        inner join flow.process_step_event_work_queue_type psewqt
                                   on psewqtest.process_step_event_work_queue_type_id = psewqt.id
                                     and psewqt.process_step_event_id = new.process_step_event_id and
                                      psewqt.archived is false
                        inner join flow.work_queue_cycle wqc
                                   on psewqtest.id =
                                      wqc.process_step_event_work_queue_type_event_status_type_id
                 where wqc.company_event_status_type_id =
                       old.company_event_status_type_id
                   and psewqtest.archived is false
                   and wqc.project_process_step_event_id = new.id
                   and wqc.date_exited_queue is null
      loop

        v_new_work_queue_type_id = null;
        v_psewqtest_id = null;

        /*This query determines if the new work_queue_type_ids match any of the for loop work_queue_type_ids*/
        select psewqtest.process_step_event_work_queue_type_id, psewqtest.id
        into v_new_work_queue_type_id,v_psewqtest_id
        from flow.process_step_event_work_queue_type_event_status_type psewqtest
               inner join flow.process_step_event_work_queue_type psewqt
                          on psewqtest.process_step_event_work_queue_type_id = psewqt.id
                            and psewqt.process_step_event_id = new.process_step_event_id and
                             psewqt.archived is false
        where (psewqtest.company_event_status_type_id = new.company_event_status_type_id or
               v_event_status_type_id = psewqtest.event_status_type_id)
          and psewqtest.archived is false
          and psewqt.id = v_old.process_step_event_work_queue_type_id;

        if v_new_work_queue_type_id is not null then
          /*if we found a match between old and new then we fill up the v_work_type_ids array
            to exclude them from being inserted below this loop because we are updating the old record to match
            what the insert would have done.*/
          v_work_type_ids = array_append(v_work_type_ids, v_old.process_step_event_work_queue_type_id);
          --raise notice 'this is my array %',v_work_type_ids;
          update flow.work_queue_cycle
          set company_event_status_type_id                      = new.company_event_status_type_id,
              process_step_event_work_queue_type_event_status_type_id = v_psewqtest_id,
              modified_by_id                                           = new.modified_by_id
          where id = v_old.id;
        else
          /*update the old records that have left the queue that aren't associated with a new work queue based
            on the new status change.*/
          update flow.work_queue_cycle
          set date_exited_queue = now(),
              modified_by_id    = new.modified_by_id
          where id = v_old.id;
        end if;
      end loop;

    /*Insert all new work queues related to the new status update and eliminate all of the work_queue_type_ids that
      we matched from old to new. */
    insert into flow.work_queue_cycle(project_process_step_event_id,
                                      company_event_status_type_id,
                                      process_step_event_work_queue_type_event_status_type_id,
                                      date_entered_queue,
                                      created_by_id)
      (select new.id,
              new.company_event_status_type_id,
              event.process_step_event_work_queue_type_event_status_type_id,
              now(),
              new.created_by_id
       from flow.get_event_work_queue_type_configs(new.process_step_event_id) event
       where case
               when v_work_type_ids is not null then
                 not event.process_step_event_work_queue_type_id = any (v_work_type_ids)
               else 1 = 1 end and
         ((new.company_event_status_type_id = event.company_event_status_type_id or
           v_event_status_type_id = event.event_status_type_id) and
          (v_company_process_step_status_type_id = event.company_process_status_type_id or
           v_process_step_status_type_id = event.process_step_status_type_id) and
          (v_company_project_status_type_id = event.company_project_status_type_id or
           v_project_status_type_id = event.project_status_type_id)))
    on conflict (project_process_step_event_id, company_event_status_type_id,
      process_step_event_work_queue_type_event_status_type_id)
    where ((date_exited_queue IS NULL) AND (project_process_step_event_id IS NOT NULL) AND
           (company_event_status_type_id IS NOT NULL) AND
           (process_step_event_work_queue_type_event_status_type_id IS NOT NULL)) do nothing;
  end if;
  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists create_events_work_queue_cycle_trg on flow.project_process_step_event;
create trigger create_events_work_queue_cycle_trg
  after insert or update
  on flow.project_process_step_event
  for each row
execute procedure flow.create_event_work_queue_cycle();



