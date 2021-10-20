CREATE OR REPLACE FUNCTION flow.is_work_queue(p_process_step_id integer,
                                              p_new_company_process_step_status_type_id integer)
  RETURNS boolean AS
$$
declare
  v_count         bigint;
  v_is_work_queue boolean;
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
                             and pswqt2.process_step_id = p_process_step_id and pswqt2.archived is false
                inner join flow.company_process_step_status_type cpsst
                           on pswqtpsst.company_process_step_status_type_id = cpsst.id and
                              cpsst.archived is false
         where cpsst.id = p_new_company_process_step_status_type_id
           and pswqtpsst.archived is false
         union
         select count(1) as my_count
         from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                inner join flow.process_step_work_queue_type pswqt2
                           on pswqtpsst.process_step_work_queue_type_id = pswqt2.id
                             and pswqt2.process_step_id = p_process_step_id and pswqt2.archived is false
                inner join flow.company_process_step_status_type cpsst
                           on p_new_company_process_step_status_type_id = cpsst.id and cpsst.archived is false
                inner join flow.process_step_status_type psst
                           on cpsst.process_step_status_type_id = psst.id and
                              psst.id = pswqtpsst.process_step_status_type_id and
                              psst.archived is false
         where pswqtpsst.archived is false) as foo;
  v_is_work_queue = false;
  if v_count > 0 then
    v_is_work_queue = true;
  end if;
  return v_is_work_queue;

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;


