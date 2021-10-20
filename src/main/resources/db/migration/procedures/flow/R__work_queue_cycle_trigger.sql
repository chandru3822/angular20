CREATE OR REPLACE FUNCTION flow.create_work_queue_cycle()
  RETURNS TRIGGER AS
$$
declare
  v_is_work_queue                   boolean;
  v_new_work_queue_type_id          integer;
  v_pswqtpsst_id                    integer;
  v_process_step_status_type_id     integer;
  v_old_process_step_status_type_id integer;
  v_old                             record;
  v_work_type_ids                   integer[];
  v_company_project_status_type_id  integer;
  v_project_status_type_id          integer;
BEGIN

  select cpst.id as company_project_status_type_id, cpst.project_status_type_id as project_status_type_id
  into v_company_project_status_type_id,v_project_status_type_id
  from flow.project p
         inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
  where p.id = new.project_id;

  /*This query looks at the new status type and determines if the new status is part of a work queue.
    If it is part of a work queue we keep processing, otherwise we set the exit date if there is currently
    a row in the work_queue_cycle table and we do this in the update section*/

  select *
  into v_is_work_queue
  from flow.is_work_queue(new.process_step_id,
                          new.company_process_step_status_type_id);


  IF (TG_OP = 'INSERT') THEN
    if v_is_work_queue is true then -- we determined it's part of a work queue then we insert all the new work queues associated with the new status.
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
                left join flow.process_step_work_queue_type_project_status_type pswqtpst
                          on pswqtpst.process_step_work_queue_type_id = pswqt2.id
                            and pswqtpst.archived is false
                left join flow.project_status_type pst on pst.id = pswqtpst.project_status_type_id and
                                                          pst.archived is false
         where pswqtpsst.company_process_step_status_type_id = new.company_process_step_status_type_id
           and pswqtpsst.archived is false
           and ((pswqtpst.company_project_status_type_id is not null and
                 pswqtpst.company_project_status_type_id = v_company_project_status_type_id) or
                (pst.id is not null and pst.id = v_project_status_type_id))
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
                left join flow.process_step_work_queue_type_project_status_type pswqtpst
                          on pswqtpst.process_step_work_queue_type_id = pswqt2.id
                            and pswqtpst.archived is false
                left join flow.project_status_type pst
                          on pst.id = pswqtpst.project_status_type_id and pst.archived is false
         where pswqtpsst.archived is false
           and ((pswqtpst.company_project_status_type_id is not null and
                 pswqtpst.company_project_status_type_id = v_company_project_status_type_id) or
                (pst.id is not null and pst.id = v_project_status_type_id)));
    end if;
    /*We only update if the statuses change*/
  elsif (TG_OP = 'UPDATE') and (old.company_process_step_status_type_id != new.company_process_step_status_type_id) THEN
    /*We determine if the new status is canceling this project_process_step and if so we
      update the work_queue_cycle table to show cancelled*/
    select count(1)
    into v_process_step_status_type_id
    from flow.company_process_step_status_type cpsst3
           inner join flow.process_step_status_type psst2
                      on cpsst3.process_step_status_type_id = psst2.id and psst2.id = 3
                        and psst2.archived is false
    where cpsst3.id = new.company_process_step_status_type_id
      and cpsst3.archived is false;

    select count(1)
    into v_old_process_step_status_type_id
    from flow.company_process_step_status_type cpsst3
           inner join flow.process_step_status_type psst2
                      on cpsst3.process_step_status_type_id = psst2.id and psst2.id = 3
                        and psst2.archived is false
    where cpsst3.id = old.company_process_step_status_type_id
      and cpsst3.archived is false;

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
        v_process_step_status_type_id = null;
        select psst2.id
        into v_process_step_status_type_id
        from flow.company_process_step_status_type cpsst3
               inner join flow.process_step_status_type psst2
                          on cpsst3.process_step_status_type_id = psst2.id and psst2.archived is false
        where cpsst3.id = new.company_process_step_status_type_id
          and cpsst3.archived is false;
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
    if v_is_work_queue is true then
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
                left join flow.process_step_work_queue_type_project_status_type pswqtpst
                          on pswqtpst.process_step_work_queue_type_id = pswqt2.id
                            and pswqtpst.archived is false
                left join flow.project_status_type pst
                          on pst.id = pswqtpst.project_status_type_id and pst.archived is false
         where pswqtpsst.company_process_step_status_type_id =
               new.company_process_step_status_type_id
           and pswqtpsst.archived is false
           and ((pswqtpst.company_project_status_type_id is not null and
                 pswqtpst.company_project_status_type_id = v_company_project_status_type_id) or
                (pst.id is not null and pst.id = v_project_status_type_id))
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
                left join flow.process_step_work_queue_type_project_status_type pswqtpst
                          on pswqtpst.process_step_work_queue_type_id = pswqt2.id
                            and pswqtpst.archived is false
                left join flow.project_status_type pst
                          on pst.id = pswqtpst.project_status_type_id and pst.archived is false
         where pswqtpsst.archived is false
           and ((pswqtpst.company_project_status_type_id is not null and
                 pswqtpst.company_project_status_type_id = v_company_project_status_type_id) or
                (pst.id is not null and pst.id = v_project_status_type_id)));
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



CREATE OR REPLACE FUNCTION flow.project_work_queue_cycle()
  RETURNS TRIGGER AS
$$
declare
  x                        record;
  v_project_status_type_id integer;
BEGIN

  select project_status_type_id
  into v_project_status_type_id
  from flow.company_project_status_type
  where id = new.company_project_status_type_id;


  for x in select pps.process_step_id,
                  pps.id,
                  cpst2.id as new_company_process_status_type_id,
                  pps2.id  as new_process_status_type_id
           from flow.project_process_step pps
                  inner join flow.company_process_step_status_type cpst2
                             on cpst2.id = pps.company_process_step_status_type_id and cpst2.archived is false
                  inner join flow.process_step_status_type pps2
                             on pps2.id = cpst2.process_step_status_type_id and pps2.archived is false
           where pps.project_id = new.id
             and pps.main is true
             and pps.archived is false
             and flow.is_work_queue(pps.process_step_id,
                                    pps.company_process_step_status_type_id) is true
    loop

      with update_data as (
        select wqc2.id
        from flow.work_queue_cycle wqc2
               inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst3
                          on wqc2.process_step_work_queue_type_process_step_status_type_id = pswqtpsst3.id
                            and pswqtpsst3.archived is false
               inner join flow.process_step_work_queue_type pswqt3
                          on pswqtpsst3.process_step_work_queue_type_id = pswqt3.id and
                             pswqt3.process_step_id = x.process_step_id and pswqt3.archived is false
        where wqc2.project_process_step_id = x.id
          --and wqc2.archived is false
          and wqc2.date_exited_queue is null
          and not exists(select pswqtpsst2.id
                         from flow.process_step_work_queue_type_process_step_status_type pswqtpsst2
                                inner join flow.process_step_work_queue_type pswqt3
                                           on pswqtpsst2.process_step_work_queue_type_id = pswqt3.id and
                                              pswqt3.process_step_id = x.process_step_id and
                                              pswqt3.archived is false
                                left join flow.process_step_work_queue_type_project_status_type pswqtpst2
                                          on pswqtpst2.process_step_work_queue_type_id = pswqt3.id and
                                             pswqtpst2.archived is false
                                left join flow.company_project_status_type cpst
                                          on cpst.id = pswqtpst2.company_project_status_type_id and
                                             cpst.archived is false
                                left join flow.process_step_work_queue_type_project_status_type pswqtpst3
                                          on pswqtpst3.process_step_work_queue_type_id = pswqt3.id and
                                             pswqtpst3.archived is false
                                left join flow.project_status_type pst2 on pst2.id = pswqtpst3.project_status_type_id
                           and pst2.archived is false
                         where pswqtpsst2.id = pswqtpsst3.id
                           and pswqtpsst2.archived is false
                           and ((cpst.id is not null and cpst.id = new.company_project_status_type_id) or
                                (pst2.id is not null and pst2.id = v_project_status_type_id))))
      update flow.work_queue_cycle wqc3
      set date_exited_queue = now(),
          modified_by_id    = new.modified_by_id
      from update_data ud
      where ud.id = wqc3.id --and wqc3.archived is false
      ;

      insert into flow.work_queue_cycle(project_process_step_id, company_process_step_status_type_id,
                                        process_step_work_queue_type_process_step_status_type_id,
                                        date_entered_queue,
                                        created_by_id)
        (select x.id, x.new_company_process_status_type_id, pswqtpsst.id, now(), new.created_by_id
         from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                inner join flow.process_step_work_queue_type pswqt2
                           on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                             and pswqt2.process_step_id = x.process_step_id and
                              pswqt2.archived is false
                left join flow.process_step_work_queue_type_project_status_type pswqtpst
                          on pswqtpst.process_step_work_queue_type_id = pswqt2.id
                            and pswqtpst.archived is false
                left join flow.project_status_type pst
                          on pst.id = pswqtpst.project_status_type_id and pst.archived is false
         where pswqtpsst.company_process_step_status_type_id = x.new_company_process_status_type_id
           and pswqtpsst.archived is false
           and ((pswqtpst.company_project_status_type_id is not null and
                 pswqtpst.company_project_status_type_id = new.company_project_status_type_id) or
                (pst.id is not null and pst.id = v_project_status_type_id))
         union
         select x.id, x.new_company_process_status_type_id, pswqtpsst.id, now(), new.created_by_id
         from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                inner join flow.process_step_work_queue_type pswqt2
                           on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                             and pswqt2.process_step_id = x.process_step_id and
                              pswqt2.archived is false
                inner join flow.company_process_step_status_type cpsst2
                           on x.new_company_process_status_type_id = cpsst2.id and
                              cpsst2.archived is false
                inner join flow.process_step_status_type ppst2
                           on pswqtpsst.process_step_status_type_id = ppst2.id and
                              cpsst2.process_step_status_type_id = ppst2.id and
                              ppst2.archived is false
                left join flow.process_step_work_queue_type_project_status_type pswqtpst
                          on pswqtpst.process_step_work_queue_type_id = pswqt2.id
                            and pswqtpst.archived is false
                left join flow.project_status_type pst
                          on pst.id = pswqtpst.project_status_type_id and pst.archived is false
         where pswqtpsst.archived is false
           and ((pswqtpst.company_project_status_type_id is not null and
                 pswqtpst.company_project_status_type_id = new.company_project_status_type_id) or
                (pst.id is not null and pst.id = v_project_status_type_id)))
      on conflict (project_process_step_id,company_process_step_status_type_id,process_step_work_queue_type_process_step_status_type_id)
      where date_exited_queue is null
        DO NOTHING;

    end loop;
  return null;
end
$$
  LANGUAGE plpgsql;


drop trigger if exists project_work_queue_cycle_trg ON flow.project;
CREATE TRIGGER project_work_queue_cycle_trg
  after update
  ON flow.project
  FOR EACH ROW
  when (old.company_project_status_type_id != new.company_project_status_type_id)
EXECUTE PROCEDURE flow.project_work_queue_cycle();


--
-- CREATE OR REPLACE FUNCTION flow.pswqtpst_work_queue_cycle()
--   RETURNS TRIGGER AS
-- $$
-- declare
--   v_company_status_ids integer[];
--   v_process_step_ids   integer;
--   x                    record;
-- BEGIN
--   if (TG_OP = 'INSERT') then
--     for x in select pswqtpsst.id,
--                     pswqtpsst.company_process_step_status_type_id,
--                     pswqt.process_step_id,
--                     pswqtpsst.process_step_status_type_id
--              from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
--                     inner join flow.process_step_work_queue_type pswqt
--                                on pswqt.id = pswqtpsst.process_step_work_queue_type_id
--                                  and pswqt.archived is false
--              where pswqtpsst.process_step_work_queue_type_id = new.process_step_work_queue_type_id
--                and pswqtpsst.archived is false
--       loop
--         insert into flow.work_queue_cycle(project_process_step_id, company_process_step_status_type_id,
--                                           process_step_work_queue_type_process_step_status_type_id, date_entered_queue,
--                                           date_exited_queue, created_by_id)
--           (select pps.id, pps.company_process_step_status_type_id, x.id, now(), null, new.created_by_id
--            from flow.project_process_step pps
--                   inner join flow.project p on p.id = pps.project_id
--                   inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
--                   inner join flow.company_process_step_status_type cpsst
--                              on cpsst.id = pps.company_process_step_status_type_id
--                   inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
--            where pps.process_step_id = x.process_step_id
--              and ((x.company_process_step_status_type_id is not null and
--                    x.company_process_step_status_type_id = cpsst.id) or
--                   (x.process_step_status_type_id is not null
--                     and x.process_step_status_type_id = psst.id))
--              and ((new.company_project_status_type_id is not null and new.company_project_status_type_id = cpst.id) or
--                   (new.project_status_type_id is not null and
--                    new.project_status_type_id = cpst.project_status_type_id)));
--
--       end loop;
--
--   elsif (TG_OP = 'UPDATE') and new.archived is true and old.archived is false then
--     for x in select pswqtpsst.id,
--                     pswqt.process_step_id,
--                     pswqtpsst.company_process_step_status_type_id,
--                     pswqt.process_step_id,
--                     pswqtpsst.process_step_status_type_id
--              from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
--                     inner join flow.process_step_work_queue_type pswqt
--                                on pswqt.id = pswqtpsst.process_step_work_queue_type_id
--                                  and pswqt.archived is false
--              where pswqtpsst.process_step_work_queue_type_id = new.process_step_work_queue_type_id
--                and pswqtpsst.archived is false
--       loop
--         with update_data as (
--           select wqc.id
--           from flow.project_process_step pps
--                  inner join flow.project p on p.id = pps.project_id
--                  inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
--                  inner join flow.work_queue_cycle wqc on wqc.project_process_step_id = pps.id
--                  inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
--                  inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
--           where pps.process_step_id = x.process_step_id
--             and wqc.company_process_step_status_type_id = cpsst.id
--             and wqc.date_exited_queue is null
--             and ((x.company_process_step_status_type_id is not null and
--                   x.company_process_step_status_type_id = cpsst.id) or (x.process_step_status_type_id is not null
--             and x.process_step_status_type_id = psst.id))
--             and ((new.company_project_status_type_id is not null and new.company_project_status_type_id = cpst.id) or
--                  (new.project_status_type_id is not null and new.project_status_type_id = cpst.project_status_type_id)))
--         update flow.work_queue_cycle wqc2
--         set date_exited_queue = now(),
--             modified_by_id = new.modified_by_id
--         from update_data ud
--         where wqc2.id = ud.id;
--       end loop;
--
--   end if;
--
--   return null;
-- end
-- $$
--   LANGUAGE plpgsql;
--
--
--
-- drop trigger if exists pswqtpst_work_queue_cycle_trg ON flow.process_step_work_queue_type_project_status_type
-- CREATE TRIGGER pswqtpst_work_queue_cycle_trg
--   after insert or update
--   ON flow.process_step_work_queue_type_project_status_type
--   FOR EACH ROW
-- EXECUTE PROCEDURE flow.pswqtpst_work_queue_cycle();
--
--
--
-- CREATE OR REPLACE FUNCTION flow.pswqtpsst_work_queue_cycle()
--   RETURNS TRIGGER AS
-- $$
-- declare
--   x                        record;
--   v_project_status_type_ids integer[];
-- v_company_project_status_type_ids integer[];
--   v_process_step integer;
-- BEGIN
--   select array_agg(coalesce(pswqtpst.project_status_type_id,-1)),array_agg(coalesce(pswqtpst.company_project_status_type_id,-1)),pswqt.process_step_id
--   into v_project_status_type_ids,v_company_project_status_type_ids,v_process_step
--   from flow.process_step_work_queue_type_project_status_type pswqtpst
--          inner join flow.process_step_work_queue_type pswqt on pswqtpst.process_step_work_queue_type_id = pswqt.id
--     and pswqt.archived is false
--   where process_step_work_queue_type_id = new.process_step_work_queue_type_id and
--     pswqtpst.archived is false
--   group by  pswqt.process_step_id;
--
--   if (TG_OP = 'INSERT') then
--
--
--     insert into flow.work_queue_cycle(project_process_step_id, company_process_step_status_type_id,
--                                       process_step_work_queue_type_process_step_status_type_id, date_entered_queue,
--                                       date_exited_queue, created_by_id)
--     (select pps.id,new.company_process_step_status_type_id,new.id,now(),null,new.created_by_id
--       from flow.project_process_step pps
--       inner join flow.project p on pps.project_id = p.id
--       inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
--       inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
--       where pps.process_step_id = v_process_step and
--             ((new.company_process_step_status_type_id is not null and new.company_process_step_status_type_id = pps.company_process_step_status_type_id) or
--              (new.process_step_status_type_id is not null and new.process_step_status_type_id = cpsst.process_step_status_type_id)) and
--         ((cpst.id = any (v_company_project_status_type_ids)) or
--        (cpst.project_status_type_id = any(v_project_status_type_ids))));
--
--   elsif (TG_OP = 'UPDATE') and new.archived is true and old.archived is false then
--
--   end if;
--
--   return null;
-- end
-- $$
--   LANGUAGE plpgsql;
--
--
--
-- drop trigger if exists pswqtpsst_work_queue_cycle_trg ON flow.process_step_work_queue_type_process_step_status_type
-- CREATE TRIGGER pswqtpsst_work_queue_cycle_trg
--   after insert
--   ON flow.process_step_work_queue_type_process_step_status_type
--   FOR EACH ROW
-- EXECUTE PROCEDURE flow.pswqtpsst_work_queue_cycle();
