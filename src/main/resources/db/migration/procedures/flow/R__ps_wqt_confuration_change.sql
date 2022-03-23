DROP FUNCTION if exists flow.ps_wqt_configuration_change(integer, integer);

CREATE OR REPLACE FUNCTION flow.ps_wqt_configuration_change(p_process_step_work_queue_type_id integer, p_created_by_id integer)
  RETURNS void as
$$
BEGIN
  with my_data as (
    select wqc.id
    from flow.work_queue_cycle wqc
           inner join flow.process_step_work_queue_type_process_step_status_type ppswqtpsst
                      on wqc.process_step_work_queue_type_process_step_status_type_id = ppswqtpsst.id
    where ppswqtpsst.process_step_work_queue_type_id = p_process_step_work_queue_type_id
      and wqc.date_exited_queue is null
  )
  update flow.work_queue_cycle wqc
  set date_exited_queue = now()
  from my_data md
  where md.id = wqc.id
    and not exists(select pps.id
                   from flow.project_process_step pps
                          inner join flow.company_process_step_status_type cpsst
                                     on pps.company_process_step_status_type_id = cpsst.id
                          inner join flow.project p on pps.project_id = p.id
                          inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
                          inner join flow.get_process_step_work_queue_type_configs(pps.process_step_id) pc
                                     on pc.process_step_work_queue_type_process_step_status_type_id =
                                        wqc.process_step_work_queue_type_process_step_status_type_id
                   where pps.id = wqc.project_process_step_id
                     and (pc.company_process_status_type_id = cpsst.id or
                          pc.process_step_status_type_id = cpsst.process_step_status_type_id)
                     and (pc.company_project_status_type_id = cpst.id or
                          pc.project_status_type_id = cpst.project_status_type_id));


  insert into flow.work_queue_cycle(project_process_step_id, company_process_step_status_type_id,
                                    process_step_work_queue_type_process_step_status_type_id,
                                    date_entered_queue,
                                    created_by_id)
    (select pps2.id, cpsst2.id, pswqtpsst3.id, now(), p_created_by_id
     from flow.project_process_step pps2
            inner join flow.company_process_step_status_type cpsst2
                       on pps2.company_process_step_status_type_id = cpsst2.id
            inner join flow.project p on pps2.project_id = p.id
            inner join flow.company_project_status_type cpst2 on p.company_project_status_type_id = cpst2.id
            inner join flow.process_step_work_queue_type pswqt4 on pswqt4.id = p_process_step_work_queue_type_id
            inner join flow.get_process_step_work_queue_type_configs(pswqt4.process_step_id) pc
                       on pc.work_queue_type_id = pswqt4.id
            inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst3
                       on pc.process_step_work_queue_type_process_step_status_type_id = pswqtpsst3.id
            left join flow.work_queue_cycle wqc3
                      on wqc3.process_step_work_queue_type_process_step_status_type_id = pswqtpsst3.id and
                         wqc3.project_process_step_id = pps2.id and wqc3.date_exited_queue is null
     where wqc3.id is null
       and pps2.process_step_id = pswqt4.process_step_id
       and (pc.company_process_status_type_id = cpsst2.id or
            pc.process_step_status_type_id = cpsst2.process_step_status_type_id)
       and (pc.company_project_status_type_id = cpst2.id or pc.project_status_type_id = cpst2.id));

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
