CREATE OR REPLACE FUNCTION flow.get_process_step_work_queue_type_configs(p_process_step_id integer)
  RETURNS TABLE(process_step_work_queue_type_process_step_status_type_id integer,
                process_step_work_queue_type_id integer,
                process_step_id integer,
                work_queue_type_id integer,
                company_process_status_type_id integer,
                process_step_status_type_id integer,
                company_project_status_type_id integer,
                project_status_type_id integer) AS
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

