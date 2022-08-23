drop function if exists flow.create_work_queue_cycle();
CREATE OR REPLACE FUNCTION flow.create_work_queue_cycle()
  RETURNS TRIGGER AS
$$
declare
  v_new_work_queue_type_id         bigint;
  v_pswqtpsst_id                   bigint;
  v_process_step_status_type_id    bigint;
  v_old                            record;
  v_work_type_ids                  bigint[];
  v_company_project_status_type_id bigint;
  v_project_status_type_id         bigint;
  x                                record;
BEGIN

  select cpst.id as company_project_status_type_id, cpst.project_status_type_id as project_status_type_id
  into v_company_project_status_type_id,v_project_status_type_id
  from flow.project p
         inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
  where p.id = new.project_id
    and p.archived is false;

  select process_step_status_type_id
  into v_process_step_status_type_id
  from flow.company_process_step_status_type
  where id = new.company_process_step_status_type_id;


  if (select count(1) > 0
      from flow.process_step_event pse
             inner join flow.process_step_event_work_queue_type psewqt
                        on pse.id = psewqt.process_step_event_id and psewqt.archived is not true
      where pse.process_step_id = new.process_step_id
        and pse.archived is not true) then
    for x in select ppse.process_step_event_id,
                    ppse.id,
                    cest.id as company_event_status_type_id,
                    est.id  as event_status_type_id
             from flow.project_process_step_event ppse
                    inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                    inner join flow.event_status_type est on cest.event_status_type_id = est.id
             where ppse.project_process_step_id = new.id
               --and pps.main is true
               and ppse.archived is false
               and exists(select psewqt.id
                          from flow.process_step_event_work_queue_type psewqt
                                 inner join flow.work_queue_type wqt2
                                            on psewqt.work_queue_type_id = wqt2.id and wqt2.archived is false
                          where psewqt.process_step_event_id = ppse.process_step_event_id
                            and psewqt.archived is false)
      loop
        perform flow.process_work_queue_cycle_events(x.id,
                                                     x.company_event_status_type_id,
                                                     x.event_status_type_id,
                                                     new.company_process_step_status_type_id,
                                                     v_process_step_status_type_id,
                                                     v_company_project_status_type_id,
                                                     v_project_status_type_id,
                                                     x.process_step_event_id,
                                                     coalesce(new.modified_by_id, new.created_by_id));
      end loop;

  end if;

  /*This query looks at the new status type and determines if the new status is part of a work queue.
    If it is part of a work queue we keep processing, otherwise we set the exit date if there is currently
    a row in the work_queue_cycle table and we do this in the update section*/
  IF (TG_OP = 'INSERT') THEN
    insert into flow.work_queue_cycle(project_process_step_id, company_process_step_status_type_id,
                                      process_step_work_queue_type_process_step_status_type_id,
                                      date_entered_queue,
                                      created_by_id)
      (select new.id,
              new.company_process_step_status_type_id,
              process.process_step_work_queue_type_process_step_status_type_id,
              now(),
              new.created_by_id
       from flow.get_process_step_work_queue_type_configs(new.process_step_id) process
       where ((new.company_process_step_status_type_id = process.company_process_status_type_id or
               v_process_step_status_type_id = process.process_step_status_type_id) and
              (v_company_project_status_type_id = process.company_project_status_type_id or
               v_project_status_type_id = process.project_status_type_id)));

    /*We only update if the statuses change*/
  elsif (TG_OP = 'UPDATE') and (old.company_process_step_status_type_id != new.company_process_step_status_type_id) THEN

    /*looping through all work_queue_cycle records where the old status matches and the project_process_step_id matches.
      Inside the loop we are querying to see if any of the old record work_queue_type_id's match what we would be
      inserting based on what the new status work_queue_type_id.  */
    for v_old in select pswqtpsst.process_step_work_queue_type_id, wqc.id
                 from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                        inner join flow.process_step_work_queue_type pswqt
                                   on pswqtpsst.process_step_work_queue_type_id = pswqt.id
                                     and pswqt.process_step_id = new.process_step_id and
                                      pswqt.archived is false
                        inner join flow.work_queue_cycle wqc
                                   on pswqtpsst.id =
                                      wqc.process_step_work_queue_type_process_step_status_type_id
                 where wqc.company_process_step_status_type_id =
                       old.company_process_step_status_type_id
                   and pswqtpsst.archived is false
                   and wqc.project_process_step_id = new.id
                   and wqc.date_exited_queue is null
      loop

        v_new_work_queue_type_id = null;
        v_pswqtpsst_id = null;

        /*This query determines if the new work_queue_type_ids match any of the for loop work_queue_type_ids*/
        select pswqtpsst.process_step_work_queue_type_id, pswqtpsst.id
        into v_new_work_queue_type_id,v_pswqtpsst_id
        from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
               inner join flow.process_step_work_queue_type pswqt
                          on pswqtpsst.process_step_work_queue_type_id = pswqt.id
                            and pswqt.process_step_id = new.process_step_id and
                             pswqt.archived is false
        where (pswqtpsst.company_process_step_status_type_id = new.company_process_step_status_type_id or
               v_process_step_status_type_id = pswqtpsst.process_step_status_type_id)
          and pswqtpsst.archived is false
          and pswqt.id = v_old.process_step_work_queue_type_id;

        if v_new_work_queue_type_id is not null then
          /*if we found a match between old and new then we fill up the v_work_type_ids array
            to exclude them from being inserted below this loop because we are updating the old record to match
            what the insert would have done.*/
          v_work_type_ids = array_append(v_work_type_ids, v_old.process_step_work_queue_type_id);
          --raise notice 'this is my array %',v_work_type_ids;
          update flow.work_queue_cycle
          set company_process_step_status_type_id                      = new.company_process_step_status_type_id,
              process_step_work_queue_type_process_step_status_type_id = v_pswqtpsst_id,
              modified_by_id                                           = new.modified_by_id,
              date_modified = now()
          where id = v_old.id;
        else
          /*update the old records that have left the queue that aren't associated with a new work queue based
            on the new status change.*/
          update flow.work_queue_cycle
          set date_exited_queue = now(),
              modified_by_id    = new.modified_by_id,
              date_modified = now()
          where id = v_old.id;
        end if;
      end loop;

    /*Insert all new work queues related to the new status update and eliminate all of the work_queue_type_ids that
      we matched from old to new. */
    insert into flow.work_queue_cycle(project_process_step_id,
                                      company_process_step_status_type_id,
                                      process_step_work_queue_type_process_step_status_type_id,
                                      date_entered_queue,
                                      created_by_id)
      (select new.id,
              new.company_process_step_status_type_id,
              process.process_step_work_queue_type_process_step_status_type_id,
              now(),
              new.created_by_id
       from flow.get_process_step_work_queue_type_configs(new.process_step_id) process
       where case
               when v_work_type_ids is not null then
                 not process.process_step_work_queue_type_id = any (v_work_type_ids)
               else 1 = 1 end
         and ((new.company_process_step_status_type_id = process.company_process_status_type_id or
               v_process_step_status_type_id = process.process_step_status_type_id) and
              (v_company_project_status_type_id = process.company_project_status_type_id or
               v_project_status_type_id = process.project_status_type_id)));
  end if;
  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists create_work_queue_cycle_trg ON flow.project_process_step;
CREATE TRIGGER create_work_queue_cycle_trg
  after INSERT or update of company_process_step_status_type_id
  ON flow.project_process_step
  FOR EACH ROW
EXECUTE PROCEDURE flow.create_work_queue_cycle();


drop function if exists flow.project_work_queue_cycle();
CREATE OR REPLACE FUNCTION flow.project_work_queue_cycle()
  RETURNS TRIGGER AS
$$
declare
  x                            record;
  v_new_project_status_type_id bigint;
BEGIN

  select project_status_type_id
  into v_new_project_status_type_id
  from flow.company_project_status_type
  where id = new.company_project_status_type_id;

  if new.archived is true then
    update flow.work_queue_cycle wqc
    set date_exited_queue = now(),
        modified_by_id    = new.modified_by_id,
        date_modified = now()
    where (exists(select wqc2.id
                  from flow.work_queue_cycle wqc2
                         inner join flow.project_process_step pps on wqc2.project_process_step_id = pps.id
                  where wqc2.id = wqc.id
                    and pps.project_id = new.id
                    and wqc2.date_exited_queue is null)
      or exists(select wqc3.id
                from flow.work_queue_cycle wqc3
                       inner join flow.project_process_step_event ppse on wqc3.project_process_step_event_id = ppse.id
                       inner join flow.project_process_step pps3 on ppse.project_process_step_id = pps3.id
                where wqc3.id = wqc.id
                  and pps3.project_id = new.id
                  and wqc3.date_exited_queue is null))
      and wqc.date_exited_queue is null;
  elsif new.archived is false and old.archived is true then
    insert into flow.work_queue_cycle(project_process_step_id, company_process_step_status_type_id,
                                      process_step_work_queue_type_process_step_status_type_id,
                                      date_entered_queue,
                                      created_by_id)
      (select pps2.id, cpsst2.id, pswqtpsst3.id, now(), new.modified_by_id
       from flow.project p
              inner join flow.project_process_step pps2 on p.id = pps2.project_id
              inner join flow.company_process_step_status_type cpsst2
                         on pps2.company_process_step_status_type_id = cpsst2.id
              inner join flow.company_project_status_type cpst2 on p.company_project_status_type_id = cpst2.id
              inner join flow.process_step_work_queue_type pswqt4 on pswqt4.process_step_id = pps2.process_step_id
              inner join flow.get_process_step_work_queue_type_configs(pswqt4.process_step_id) pc
                         on pc.work_queue_type_id = pswqt4.work_queue_type_id
              inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst3
                         on pc.process_step_work_queue_type_process_step_status_type_id = pswqtpsst3.id
              left join flow.work_queue_cycle wqc3
                        on wqc3.process_step_work_queue_type_process_step_status_type_id = pswqtpsst3.id and
                           wqc3.project_process_step_id = pps2.id and wqc3.date_exited_queue is null
       where wqc3.id is null
         and p.id = new.id
         and p.archived is false
         and pps2.process_step_id = pswqt4.process_step_id
         and (pc.company_process_status_type_id = cpsst2.id or
              pc.process_step_status_type_id = cpsst2.process_step_status_type_id)
         and (pc.company_project_status_type_id = cpst2.id or pc.project_status_type_id = cpst2.project_status_type_id))
    on conflict (project_process_step_id, company_process_step_status_type_id,
      process_step_work_queue_type_process_step_status_type_id)
    where ((date_exited_queue IS NULL) AND (project_process_step_id IS NOT NULL) AND
           (company_process_step_status_type_id IS NOT NULL) AND
           (process_step_work_queue_type_process_step_status_type_id IS NOT NULL)) do nothing;


    insert into flow.work_queue_cycle(project_process_step_event_id, company_event_status_type_id,
                                      process_step_event_work_queue_type_event_status_type_id,
                                      date_entered_queue,
                                      created_by_id)
      (select ppse.id, cest.id, pswqtpsst3.id, now(), new.modified_by_id
       from flow.project p
              inner join flow.project_process_step pps2 on p.id = pps2.project_id
              inner join flow.company_process_step_status_type cpsst2
                         on pps2.company_process_step_status_type_id = cpsst2.id
              inner join flow.project_process_step_event ppse on pps2.id = ppse.project_process_step_id
              inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
              inner join flow.company_project_status_type cpst2 on p.company_project_status_type_id = cpst2.id
              inner join flow.process_step_event_work_queue_type pswqt4
                         on pswqt4.process_step_event_id = ppse.process_step_event_id
              inner join flow.get_event_work_queue_type_configs(pswqt4.process_step_event_id) pc
                         on pc.work_queue_type_id = pswqt4.work_queue_type_id
              inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst3
                         on pc.process_step_event_work_queue_type_event_status_type_id = pswqtpsst3.id
              left join flow.work_queue_cycle wqc3
                        on wqc3.process_step_event_work_queue_type_event_status_type_id = pswqtpsst3.id and
                           wqc3.project_process_step_event_id = ppse.id and wqc3.date_exited_queue is null
       where wqc3.id is null
         and p.id = new.id
         and p.archived is false
         and ppse.process_step_event_id = pswqt4.process_step_event_id
         and (pc.company_event_status_type_id = cest.id or pc.event_status_type_id = cest.event_status_type_id)
         and (pc.company_process_status_type_id = cpsst2.id or
              pc.process_step_status_type_id = cpsst2.process_step_status_type_id)
         and (pc.company_project_status_type_id = cpst2.id or pc.project_status_type_id = cpst2.project_status_type_id))
    on conflict (project_process_step_event_id, company_event_status_type_id,
      process_step_event_work_queue_type_event_status_type_id)
    where ((date_exited_queue IS NULL) AND (project_process_step_event_id IS NOT NULL) AND
           (company_event_status_type_id IS NOT NULL) AND
           (process_step_event_work_queue_type_event_status_type_id IS NOT NULL)) do nothing;
  else
    for x in select ppse.process_step_event_id,
                    ppse.id,
                    cpst2.id as company_process_status_type_id,
                    pps2.id  as process_status_type_id,
                    cest.id  as company_event_status_type_id,
                    est.id   as event_status_type_id
             from flow.project_process_step pps
                    inner join flow.company_process_step_status_type cpst2
                               on cpst2.id = pps.company_process_step_status_type_id and cpst2.archived is false
                    inner join flow.process_step_status_type pps2
                               on pps2.id = cpst2.process_step_status_type_id and pps2.archived is false
                    inner join flow.project_process_step_event ppse on pps.id = ppse.project_process_step_id
                    inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                    inner join flow.event_status_type est on cest.event_status_type_id = est.id
             where pps.project_id = new.id
               --and pps.main is true
               and pps.archived is false
               and exists(select psewqt.id
                          from flow.process_step_event_work_queue_type psewqt
                                 inner join flow.work_queue_type wqt2
                                            on psewqt.work_queue_type_id = wqt2.id and wqt2.archived is false
                          where psewqt.process_step_event_id = ppse.process_step_event_id
                            and psewqt.archived is false)
      loop
        perform flow.process_work_queue_cycle_events(x.id,
                                                     x.company_event_status_type_id,
                                                     x.event_status_type_id,
                                                     x.company_process_status_type_id,
                                                     x.process_status_type_id,
                                                     new.company_project_status_type_id,
                                                     v_new_project_status_type_id,
                                                     x.process_step_event_id,
                                                     coalesce(new.modified_by_id, new.created_by_id));
      end loop;

    for x in select pps.process_step_id,
                    pps.id,
                    cpst2.id as company_process_status_type_id,
                    pps2.id  as process_status_type_id
             from flow.project_process_step pps
                    inner join flow.company_process_step_status_type cpst2
                               on cpst2.id = pps.company_process_step_status_type_id and cpst2.archived is false
                    inner join flow.process_step_status_type pps2
                               on pps2.id = cpst2.process_step_status_type_id and pps2.archived is false
             where pps.project_id = new.id
               --and pps.main is true
               and pps.archived is false
               and exists(select pswqt2.id
                          from flow.process_step_work_queue_type pswqt2
                                 inner join flow.work_queue_type wqt
                                            on pswqt2.work_queue_type_id = wqt.id and wqt.archived is false
                          where pswqt2.process_step_id = pps.process_step_id
                            and pswqt2.archived is false)
      loop
        update flow.work_queue_cycle
        set date_exited_queue = now(),
            modified_by_id    = new.modified_by_id,
            date_modified = now()
        where project_process_step_id = x.id
          and company_process_step_status_type_id = x.company_process_status_type_id
          and not exists
          (select process.process_step_work_queue_type_process_step_status_type_id
           from flow.get_process_step_work_queue_type_configs(x.process_step_id) process
           where ((x.company_process_status_type_id = process.company_process_status_type_id or
                   x.process_status_type_id = process.process_step_status_type_id) and
                  (new.company_project_status_type_id = process.company_project_status_type_id or
                   v_new_project_status_type_id = process.project_status_type_id)))
          and date_exited_queue is null;

        insert into flow.work_queue_cycle(project_process_step_id,
                                          company_process_step_status_type_id,
                                          process_step_work_queue_type_process_step_status_type_id,
                                          date_entered_queue,
                                          created_by_id)
          (select x.id,
                  x.company_process_status_type_id,
                  process.process_step_work_queue_type_process_step_status_type_id,
                  now(),
                  new.created_by_id
           from flow.get_process_step_work_queue_type_configs(x.process_step_id) process
           where ((x.company_process_status_type_id = process.company_process_status_type_id or
                   x.process_status_type_id = process.process_step_status_type_id) and
                  (new.company_project_status_type_id = process.company_project_status_type_id or
                   v_new_project_status_type_id = process.project_status_type_id)))
        on conflict (project_process_step_id, company_process_step_status_type_id,
          process_step_work_queue_type_process_step_status_type_id)
        where ((date_exited_queue IS NULL) AND (project_process_step_id IS NOT NULL) AND
               (company_process_step_status_type_id IS NOT NULL) AND
               (process_step_work_queue_type_process_step_status_type_id IS NOT NULL)) do nothing;
      end loop;
  end if;

  return null;
end
$$
  LANGUAGE plpgsql;


drop trigger if exists project_work_queue_cycle_trg ON flow.project;
CREATE TRIGGER project_work_queue_cycle_trg
  after update
  ON flow.project
  FOR EACH ROW
  when ((old.company_project_status_type_id != new.company_project_status_type_id) or (new.archived is true )or
        (old.archived is true and new.archived is false))
EXECUTE PROCEDURE flow.project_work_queue_cycle();
