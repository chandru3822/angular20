drop function if exists flow.get_process_step_work_queue_type_configs(p_process_step_id bigint);
  CREATE OR REPLACE FUNCTION flow.get_process_step_work_queue_type_configs(p_process_step_id bigint)
  RETURNS TABLE(process_step_work_queue_type_process_step_status_type_id bigint,
                process_step_work_queue_type_id bigint,
                process_step_id bigint,
                work_queue_type_id bigint,
                company_process_status_type_id bigint,
                process_step_status_type_id bigint,
                company_project_status_type_id bigint,
                project_status_type_id bigint) AS
$BODY$
declare

BEGIN
    return query
      select pswqtpsst.id as process_step_work_queue_type_process_step_status_type_id,
             pswqt.id as process_step_work_queue_type_id,
             pswqt.process_step_id,
             pswqt.work_queue_type_id,
             coalesce(cpsst.id,0) as company_process_status_type_id,
             coalesce(psst.id,0) as process_step_status_type_id,
             coalesce(cpst.id, 0) as company_project_status_type_id,
             coalesce(pst.id,0) as project_status_type_id
      from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
             inner join flow.process_step_work_queue_type pswqt  on pswqtpsst.process_step_work_queue_type_id = pswqt.id and pswqt.archived is false
             inner join flow.work_queue_type wqt on pswqt.work_queue_type_id = wqt.id and wqt.archived is false
             inner join flow.process_step ps on pswqt.process_step_id = ps.id and ps.archived is false
             left join flow.process_step_work_queue_type_project_status_type pswqtpst on pswqt.id = pswqtpst.process_step_work_queue_type_id and pswqtpst.archived is false
             left join flow.company_process_step_status_type cpsst on pswqtpsst.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
             left join flow.process_step_status_type psst on pswqtpsst.process_step_status_type_id = psst.id and psst.archived is false
             left join flow.company_project_status_type cpst on pswqtpst.company_project_status_type_id = cpst.id and cpst.archived is false
             left join flow.project_status_type pst on pswqtpst.project_status_type_id = pst.id and pst.archived is false
      where pswqt.process_step_id = p_process_step_id and pswqtpsst.archived is false;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

