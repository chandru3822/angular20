DROP FUNCTION if exists flow.ps_wqt_configuration_change(integer,integer);

CREATE OR REPLACE FUNCTION flow.ps_wqt_configuration_change(p_process_step_work_queue_type_id integer,p_created_by_id integer)
RETURNS void as
$$
declare
  v_root_project_status_type_ids integer[];
  v_company_project_status_type_ids integer[];
  v_root_process_step_status_type_ids integer[];
  v_company_process_step_status_type_ids integer[];
  v_process_step_id  integer;
BEGIN

  select array_agg(coalesce(pswqtpst.project_status_type_id,-1)),array_agg(coalesce(pswqtpst.company_project_status_type_id,-1))
  into v_root_project_status_type_ids,v_company_project_status_type_ids
  from flow.process_step_work_queue_type pswqt
  inner join flow.process_step_work_queue_type_project_status_type pswqtpst on pswqt.id = pswqtpst.process_step_work_queue_type_id
  and pswqtpst.archived is false
  where pswqt.id = p_process_step_work_queue_type_id
  and pswqt.archived is false;

  select array_agg(coalesce(pswqtpsst.process_step_status_type_id,-1)),array_agg(coalesce(pswqtpsst.company_process_step_status_type_id,-1))
  into v_root_process_step_status_type_ids,v_company_process_step_status_type_ids
  from flow.process_step_work_queue_type pswqt
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst on pswqt.id = pswqtpsst.process_step_work_queue_type_id
    and pswqtpsst.archived is false
  where pswqt.id = p_process_step_work_queue_type_id
    and pswqt.archived is false;

  select pswqt3.process_step_id
  into v_process_step_id
  from flow.process_step_work_queue_type pswqt3
  where pswqt3.id = p_process_step_work_queue_type_id;

  with update_data as (
  select wqc1.id
  from flow.work_queue_cycle wqc1
         inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2 on wqc1.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
    and pswqtpsst2.process_step_work_queue_type_id = p_process_step_work_queue_type_id
  where wqc1.date_exited_queue is null
    and not exists (select wqc.id
                    from flow.work_queue_cycle wqc
                           inner join flow.project_process_step pps on wqc.project_process_step_id = pps.id and pps.process_step_id = v_process_step_id
                           inner join flow.project p on pps.project_id = p.id
                           inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
                           inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
                           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                           inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
                           inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2 on wqc.process_step_work_queue_type_process_step_status_type_id = pswqtpsst2.id
                           inner join flow.process_step_work_queue_type_project_status_type pswqtpst2 on pswqtpst2.process_step_work_queue_type_id = pswqtpsst2.process_step_work_queue_type_id
                      and pswqtpsst2.archived is false
                          inner join flow.process_step_work_queue_type pswqt2  on pswqtpsst2.process_step_work_queue_type_id = pswqt2.id
                          and pswqt2.archived is false and pswqt2.id = p_process_step_work_queue_type_id
                          inner join flow.work_queue_type wqt on pswqt2.work_queue_type_id = wqt.id and wqt.archived is false
                    where ((pswqtpst2.company_project_status_type_id is not null and pswqtpst2.company_project_status_type_id = cpst.id) or
                           (pswqtpst2.project_status_type_id is not null and pswqtpst2.project_status_type_id = pst.id)) and
                      ((pswqtpsst2.company_process_step_status_type_id is not null and pswqtpsst2.company_process_step_status_type_id = cpsst.id) or
                       (pswqtpsst2.process_step_status_type_id is not null and  pswqtpsst2.process_step_status_type_id = psst.id)) and
                          wqc.date_exited_queue is null and wqc.id = wqc1.id and
                          ((cpst.id = any( v_company_project_status_type_ids) or pst.id = any(v_root_project_status_type_ids))
                          and (cpsst.id = any(v_company_process_step_status_type_ids) or psst.id = any(v_root_process_step_status_type_ids)))))
  update flow.work_queue_cycle wqc2
  set date_exited_queue = now(),
      modified_by_id = p_created_by_id
  from update_data ud
  where ud.id = wqc2.id;


  insert into flow.work_queue_cycle(project_process_step_id, company_process_step_status_type_id,
                                    process_step_work_queue_type_process_step_status_type_id,
                                    date_entered_queue,
                                    created_by_id)
  (select pps.id,pps.company_process_step_status_type_id,pswqtpsst2.id,now(),p_created_by_id
   from flow.project_process_step pps
          inner join flow.project p on pps.project_id = p.id
          inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
          inner join flow.project_status_type pst on cpst.project_status_type_id = pst.id
          inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
          inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
          inner join flow.process_step_work_queue_type pswqt2  on pswqt2.id = p_process_step_work_queue_type_id
     and pswqt2.archived is false
          inner join flow.process_step_work_queue_type_process_step_status_type pswqtpsst2 on pswqt2.id = pswqtpsst2.process_step_work_queue_type_id
     and pswqtpsst2.archived is false
          inner join flow.work_queue_type wqt on pswqt2.work_queue_type_id = wqt.id and wqt.archived is false
          inner join flow.process_step_work_queue_type_project_status_type pswqtpst2 on pswqtpst2.process_step_work_queue_type_id = pswqtpsst2.process_step_work_queue_type_id
   where ((pswqtpst2.company_project_status_type_id is not null and pswqtpst2.company_project_status_type_id = cpst.id) or
           (pswqtpst2.project_status_type_id is not null and pswqtpst2.project_status_type_id = pst.id)) and
         ((pswqtpsst2.company_process_step_status_type_id is not null and pswqtpsst2.company_process_step_status_type_id = cpsst.id) or
          (pswqtpsst2.process_step_status_type_id is not null and  pswqtpsst2.process_step_status_type_id = psst.id)) and
         pps.process_step_id = v_process_step_id and ((cpst.id = any( v_company_project_status_type_ids) or pst.id = any(v_root_project_status_type_ids))
       and (cpsst.id = any(v_company_process_step_status_type_ids) or psst.id = any(v_root_process_step_status_type_ids))))
  on conflict (project_process_step_id,company_process_step_status_type_id,process_step_work_queue_type_process_step_status_type_id)
  where date_exited_queue is null
    DO NOTHING;

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
