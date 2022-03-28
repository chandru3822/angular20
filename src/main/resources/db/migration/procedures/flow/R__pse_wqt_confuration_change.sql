DROP FUNCTION if exists flow.pse_wqt_configuration_change(integer,integer);

CREATE OR REPLACE FUNCTION flow.pse_wqt_configuration_change(p_process_step_event_work_queue_type_id integer,p_created_by_id integer)
RETURNS void as
$$
BEGIN

  with my_data as (
    select wqc.id
    from flow.work_queue_cycle wqc
           inner join flow.process_step_event_work_queue_type_event_status_type psewqtpsst
                      on wqc.process_step_event_work_queue_type_event_status_type_id = psewqtpsst.id
    where psewqtpsst.process_step_event_work_queue_type_id = p_process_step_event_work_queue_type_id
      and wqc.date_exited_queue is null
  )
  update flow.work_queue_cycle wqc
  set date_exited_queue = now()
  from my_data md
  where md.id = wqc.id
    and not exists(select ppse.id
                   from flow.project_process_step_event ppse
                          inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                          inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
                          inner join flow.company_process_step_status_type cpsst
                                     on pps.company_process_step_status_type_id = cpsst.id
                          inner join flow.project p on pps.project_id = p.id
                          inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
                          inner join flow.get_event_work_queue_type_configs(ppse.process_step_event_id) pc
                                     on pc.process_step_event_work_queue_type_event_status_type_id =
                                        wqc.process_step_event_work_queue_type_event_status_type_id
                   where ppse.id = wqc.project_process_step_event_id
                     and (pc.company_event_status_type_id = cest.id or pc.event_status_type_id = cest.event_status_type_id) and
                         (pc.company_process_status_type_id = cpsst.id or
                          pc.process_step_status_type_id = cpsst.process_step_status_type_id)
                     and (pc.company_project_status_type_id = cpst.id or
                          pc.project_status_type_id = cpst.project_status_type_id));


  insert into flow.work_queue_cycle(project_process_step_event_id, company_event_status_type_id,
                                    process_step_event_work_queue_type_event_status_type_id,
                                    date_entered_queue,
                                    created_by_id)
    (select ppse.id, cest.id, pswqtpsst3.id, now(), p_created_by_id
     from flow.project_process_step_event ppse
            inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
            inner join flow.project_process_step pps2 on ppse.project_process_step_id = pps2.id
            inner join flow.company_process_step_status_type cpsst2
                       on pps2.company_process_step_status_type_id = cpsst2.id
            inner join flow.project p on pps2.project_id = p.id
            inner join flow.company_project_status_type cpst2 on p.company_project_status_type_id = cpst2.id
            inner join flow.process_step_event_work_queue_type pswqt4 on pswqt4.id = p_process_step_event_work_queue_type_id
            inner join flow.get_event_work_queue_type_configs(pswqt4.process_step_event_id) pc
                       on pc.work_queue_type_id = pswqt4.id
            inner join flow.process_step_event_work_queue_type_event_status_type pswqtpsst3
                       on pc.process_step_event_work_queue_type_event_status_type_id = pswqtpsst3.id
            left join flow.work_queue_cycle wqc3
                      on wqc3.process_step_event_work_queue_type_event_status_type_id = pswqtpsst3.id and
                         wqc3.project_process_step_event_id = ppse.id and wqc3.date_exited_queue is null
     where wqc3.id is null
       and ppse.process_step_event_id = pswqt4.process_step_event_id
       and (pc.company_event_status_type_id = cest.id or pc.event_status_type_id = cest.event_status_type_id) and
           (pc.company_process_status_type_id = cpsst2.id or
            pc.process_step_status_type_id = cpsst2.process_step_status_type_id)
       and (pc.company_project_status_type_id = cpst2.id or pc.project_status_type_id = cpst2.id))
  on conflict (project_process_step_event_id, company_event_status_type_id,
    process_step_event_work_queue_type_event_status_type_id)
  where ((date_exited_queue IS NULL) AND (project_process_step_event_id IS NOT NULL) AND
         (company_event_status_type_id IS NOT NULL) AND
         (process_step_event_work_queue_type_event_status_type_id IS NOT NULL)) do nothing;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
