CREATE OR REPLACE FUNCTION flow.create_work_queue_cycle()
  RETURNS TRIGGER AS
$$
declare
  v_count                           bigint;
  v_new_work_queue_type_id          integer;
  v_pswqtpsst_id                    integer;
  v_process_step_status_type_id     integer;
  v_old_process_step_status_type_id integer;
  v_old                             record;
  v_cancel_records                  record;
  v_work_type_ids                   integer[];
BEGIN

  /*This query looks at the new status type and determines if the new status is part of a work queue.
    If it is part of a work queue we keep processing, otherwise we set the exit date if there is currently
    a row in the work_queue_cycle table and we do this in the update section*/
  select sum(foo.my_count)
  into v_count
  from (
         select count(1) as my_count
         from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                inner join flow.process_step_work_queue_type pswqt2
                           on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                             and pswqt2.process_step_id = new.process_step_id and pswqt2.archived is false
                inner join flow.company_process_step_status_type cpsst
                           on pswqtpsst.company_process_step_status_type_id = cpsst.id and
                              cpsst.archived is false
         where cpsst.id = new.company_process_step_status_type_id
           and pswqtpsst.archived is false
         union
         select count(1) as my_count
         from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                inner join flow.process_step_work_queue_type pswqt2
                           on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                             and pswqt2.process_step_id = new.process_step_id and pswqt2.archived is false
                inner join flow.company_process_step_status_type cpsst
                           on new.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
                inner join flow.process_step_status_type psst
                           on cpsst.process_step_status_type_id = psst.id and
                              psst.id = pswqtpsst.process_step_status_type_id and
                              psst.archived is false
         where pswqtpsst.archived is false) as foo;

  IF (TG_OP = 'INSERT') THEN
    if v_count > 0 then -- we determined it's part of a work queue then we insert all the new work queues associated with the new status.
      insert into flow.work_queue_cycle(project_process_step_id, company_process_step_status_type_id,
                                        process_step_work_queue_type_process_step_status_type_id,
                                        date_entered_queue,
                                        created_by_id)
        (select new.id, new.company_process_step_status_type_id, pswqtpsst.id, now(), new.created_by_id
         from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                inner join flow.process_step_work_queue_type pswqt2
                           on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                             and pswqt2.process_step_id = new.process_step_id and
                              pswqt2.archived is false
         where pswqtpsst.company_process_step_status_type_id = new.company_process_step_status_type_id
           and pswqtpsst.archived is false
         union
         select new.id, new.company_process_step_status_type_id, pswqtpsst.id, now(), new.created_by_id
         from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                inner join flow.process_step_work_queue_type pswqt2
                           on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                             and pswqt2.process_step_id = new.process_step_id and
                              pswqt2.archived is false
                inner join flow.company_process_step_status_type cpsst2
                           on new.company_process_step_status_type_id = cpsst2.id and
                              cpsst2.archived is false
                inner join flow.process_step_status_type ppst2
                           on pswqtpsst.process_step_status_type_id = ppst2.id and
                              cpsst2.process_step_status_type_id = ppst2.id and
                              ppst2.archived is false
         where pswqtpsst.archived is false);
    end if;
    /*We only update if the statuses change*/
  elsif (TG_OP = 'UPDATE') and
        new.company_process_step_status_type_id != old.company_process_step_status_type_id THEN
    /*We determine if the new status is canceling this project_process_step and if so we
      update the work_queue_cycle table to show cancelled*/
    select count(1)
    into v_process_step_status_type_id
    from flow.company_process_step_status_type cpsst3
           inner join flow.process_step_status_type psst2
                      on cpsst3.process_step_status_type_id = psst2.id and psst2.id = 3
                      and psst2.archived is false
    where cpsst3.id = new.company_process_step_status_type_id and cpsst3.archived is false;

    select count(1)
    into v_old_process_step_status_type_id
    from flow.company_process_step_status_type cpsst3
           inner join flow.process_step_status_type psst2
                      on cpsst3.process_step_status_type_id = psst2.id and psst2.id = 3
                  and psst2.archived is false
    where cpsst3.id = old.company_process_step_status_type_id and cpsst3.archived is false;


    if v_old_process_step_status_type_id > 0 and v_process_step_status_type_id > 0 then --do nothing
      return null;
    elsif v_old_process_step_status_type_id > 0 and v_process_step_status_type_id = 0 then
      for v_cancel_records in select *
                              from flow.work_queue_cycle
                              where project_process_step_id = new.id
                                and is_cancelled is true
        loop
          update flow.work_queue_cycle
          set is_cancelled       = false,
              date_entered_queue = now(),
              date_exited_queue  = null
          where id = v_cancel_records.id;
        end loop;

    elsif v_process_step_status_type_id > 0 and v_old_process_step_status_type_id = 0 then
      update flow.work_queue_cycle
      set date_exited_queue = now(),
          is_cancelled      = true
      where project_process_step_id = new.id
        and company_process_step_status_type_id = old.company_process_step_status_type_id;
    else
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
        loop

          v_new_work_queue_type_id = null;
          v_process_step_status_type_id = null;
          select psst2.id
          into v_process_step_status_type_id
          from flow.company_process_step_status_type cpsst3
                 inner join flow.process_step_status_type psst2
                            on cpsst3.process_step_status_type_id = psst2.id and psst2.archived is false
          where cpsst3.id = new.company_process_step_status_type_id and cpsst3.archived is false;
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
      if v_count > 0 then
        /*Insert all new work queues related to the new status update and eliminate all of the work_queue_type_ids that
          we matched from old to new. */
        insert into flow.work_queue_cycle(project_process_step_id,
                                          company_process_step_status_type_id,
                                          process_step_work_queue_type_process_step_status_type_id,
                                          date_entered_queue,
                                          created_by_id)
          (select new.id,
                  new.company_process_step_status_type_id,
                  pswqtpsst.id,
                  now(),
                  new.created_by_id
           from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                  inner join flow.process_step_work_queue_type pswqt2
                             on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                               and pswqt2.process_step_id = new.process_step_id and
                                pswqt2.archived is false and
                                case
                                  when v_work_type_ids is not null then
                                    not pswqt2.id = any (v_work_type_ids)
                                  else 1 = 1 end--- eliminates all work_queue_type_ids that we updated in the for loop above.
           where pswqtpsst.company_process_step_status_type_id =
                 new.company_process_step_status_type_id
             and pswqtpsst.archived is false
           union
           select new.id,
                  new.company_process_step_status_type_id,
                  pswqtpsst.id,
                  now(),
                  new.created_by_id
           from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                  inner join flow.process_step_work_queue_type pswqt2
                             on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                               and pswqt2.process_step_id = new.process_step_id and
                                pswqt2.archived is false and
                                case
                                  when v_work_type_ids is not null then
                                    not pswqt2.id = any (v_work_type_ids)
                                  else 1 = 1 end--- eliminates all work_queue_type_ids that we updated in the for loop above.
                  inner join flow.company_process_step_status_type cpsst2
                             on new.company_process_step_status_type_id = cpsst2.id and
                                cpsst2.archived is false
                  inner join flow.process_step_status_type ppst2
                             on pswqtpsst.process_step_status_type_id = ppst2.id and
                                cpsst2.process_step_status_type_id = ppst2.id and
                                ppst2.archived is false
           where pswqtpsst.archived is false)
        on conflict (project_process_step_id,company_process_step_status_type_id,process_step_work_queue_type_process_step_status_type_id)
          do update set date_exited_queue = null;
      end if;
    end if;
  end if;
  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists create_work_queue_cycle_trg ON flow.project_process_step;
CREATE TRIGGER create_work_queue_cycle_trg
  after INSERT or update
  ON flow.project_process_step
  FOR EACH ROW
EXECUTE PROCEDURE flow.create_work_queue_cycle();
