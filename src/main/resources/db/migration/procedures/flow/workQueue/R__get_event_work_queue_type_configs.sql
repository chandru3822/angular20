drop function if exists flow.get_event_work_queue_type_configs(p_process_step_event_id bigint);
CREATE OR REPLACE FUNCTION flow.get_event_work_queue_type_configs(p_process_step_event_id bigint)
  RETURNS TABLE(process_step_event_work_queue_type_event_status_type_id bigint,
                process_step_event_work_queue_type_id bigint,
                process_step_id bigint,
                event_id bigint,
                work_queue_type_id bigint,
                company_event_status_type_id bigint,
                event_status_type_id bigint,
                company_process_status_type_id bigint,
                process_step_status_type_id bigint,
                company_project_status_type_id bigint,
                project_status_type_id bigint) AS
$BODY$
declare

BEGIN
    return query
      select psewqtest.id as process_step_event_work_queue_type_event_status_type_id,
             psewqt.id as process_step_event_work_queue_type_id,
             pse.process_step_id,
             pse.event_id,
             psewqt.work_queue_type_id,
             coalesce(cest.id,0) as company_event_status_type_id,
             coalesce(est.id,0) as event_status_type_id,
             coalesce(cpsst.id,0) as company_process_status_type_id,
             coalesce(psst.id,0) as process_step_status_type_id,
             coalesce(cpst.id,0) as company_project_status_type_id,
             coalesce(pst.id,0) as project_status_type_id
      from flow.process_step_event_work_queue_type_event_status_type psewqtest
             inner join flow.process_step_event_work_queue_type psewqt  on psewqtest.process_step_event_work_queue_type_id = psewqt.id and psewqt.archived is false
             inner join flow.work_queue_type wqt on psewqt.work_queue_type_id = wqt.id and wqt.archived is false
             inner join flow.process_step_event pse on psewqt.process_step_event_id = pse.id and psewqt.archived is false
             inner join flow.event e on pse.event_id = e.id and e.archived is false
             left join flow.process_step_event_work_queue_type_process_step_status_type psewqtpsst on psewqtpsst.process_step_event_work_queue_type_id = psewqt.id and psewqtpsst.archived is false
             left join flow.process_step_event_work_queue_type_project_status_type psewqtpst on psewqtpst.process_step_event_work_queue_type_id = psewqt.id and psewqtpst.archived is false
             left join flow.company_event_status_type cest on psewqtest.company_event_status_type_id = cest.id and cest.archived is false
             left join flow.event_status_type est on psewqtest.event_status_type_id = est.id and est.archived is false
             left join flow.company_process_step_status_type cpsst on psewqtpsst.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
             left join flow.process_step_status_type psst on psewqtpsst.process_step_status_type_id = psst.id and psst.archived is false
             left join flow.company_project_status_type cpst on psewqtpst.company_project_status_type_id = cpst.id and cpst.archived is false
             left join flow.project_status_type pst on psewqtpst.project_status_type_id = pst.id and pst.archived is false
      where  psewqtest.archived is not true and pse.id = p_process_step_event_id;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

