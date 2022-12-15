package com.albatross.api.v1.flow.queries;

public class SmartlistQueryv2 {

  //language=PostgreSQL
  public final static String getMine = """
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public "isPublic",
      s.owner_id,
      s.date_created,
      s.date_modified,
      s.created_by_id,
      s.modified_by_id,
      s.archived,
      s.main_process_steps,
      s.project_details,
      s.work_queue_type_id,
      s.primary_user_position,
      ot.object_type,
      cot.object_type_id,
      concat(u.first_name, ' ', u.last_name) "owner"
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    left join flow.object_type ot1 on ot1.id = s.view_object_type_id
    inner join flow.user u on u.id = s.owner_id
    where
      cot.company_id = :companyId and
      s.owner_id = :userId and
      s.archived is not true and
      s.work_queue_type_id is null
    """;

  //language=PostgreSQL
  public final static String getPublic = """
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public "isPublic",
      s.owner_id,
      s.date_created,
      s.date_modified,
      s.created_by_id,
      s.modified_by_id,
      s.archived,
      s.main_process_steps,
      s.project_details,
      s.work_queue_type_id,
      s.primary_user_position,
      ot.object_type,
      cot.object_type_id,
      concat(u.first_name, ' ', u.last_name) "owner"
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    left join flow.object_type ot1 on ot1.id = s.view_object_type_id
    inner join flow.user u on u.id = s.owner_id
    where
      cot.company_id = :companyId and
      s.public and
      s.archived is not true and
      s.work_queue_type_id is null
    """;

  //language=PostgreSQL
  public final static String getById = """
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public "isPublic",
      s.owner_id,
      s.date_created,
      s.date_modified,
      s.created_by_id,
      s.modified_by_id,
      s.archived,
      s.main_process_steps,
      s.project_details,
      s.work_queue_type_id,
      s.primary_user_position,
      ot.object_type,
      cot.object_type_id,
      ot1.object_type as view_object_type,
      concat(u.first_name, ' ', u.last_name) as owner,
      coalesce((
       select array_to_json(array_agg(row_to_json(eventWorkQueueTypes)))
       from (
          select pswqt.id,
                 pswqt.work_queue_type_id as "workQueueTypeId",
                 pswqt.process_step_event_id as "processStepEventId",
                 wqt.work_queue_type as "workQueueType",
                 wqc.work_queue_category as "workQueueCategory",
                 pswqt.archived,
                 coalesce((
                   select array_to_json(array_agg(row_to_json(projectStatuses))) from (
                     select pswqtpst.id,
                            pswqtpst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
                            pswqtpst.company_project_status_type_id as "companyProjectStatusTypeId",
                            coalesce(pswqtpst.project_status_type_id, cpst.project_status_type_id) as "projectStatusTypeId",
                            case when pswqtpst.project_status_type_id is not null then true else false end as "isRoot",
                            case when pswqtpst.project_status_type_id is not null then 'Category' else 'Project Status' end as "group",
                            case when pswqtpst.project_status_type_id is not null then concat(coalesce(cpst.project_status_type, pst.project_status_type), 'PST') else concat(coalesce(cpst.project_status_type, pst.project_status_type), 'CPST') end as "uniqueText",
                            pswqtpst.archived,
                            coalesce(cpst.project_status_type, pst.project_status_type) as "projectStatusType"
                     from flow.process_step_event_work_queue_type_project_status_type pswqtpst
                     left join flow.company_project_status_type cpst on pswqtpst.company_project_status_type_id = cpst.id
                     left join flow.project_status_type pst on pswqtpst.project_status_type_id = pst.id
                     where pswqtpst.process_step_event_work_queue_type_id = pswqt.id and
                           pswqtpst.archived is not true
                     order by pst.project_status_type, cpst.project_status_type
                 ) projectStatuses), '[]') as "projectStatuses",
                 coalesce((
                   select array_to_json(array_agg(row_to_json(processStepStatuses)))
                   from (
                     select pswqtpsst.id,
                            pswqtpsst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
                            pswqtpsst.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                            coalesce(pswqtpsst.process_step_status_type_id, cpsst.process_step_status_type_id) as "processStepStatusTypeId",
                            pswqtpsst.archived,
                            case when pswqtpsst.process_step_status_type_id is not null then true else false end as "isRoot",
                            case when pswqtpsst.process_step_status_type_id is not null then 'Category' else 'Process Step Status' end as "group",
                            case when pswqtpsst.process_step_status_type_id is not null then concat(coalesce(cpsst.process_step_status_type, psst.process_step_status_type), 'PSST') else concat(coalesce(cpsst.process_step_status_type, psst.process_step_status_type), 'CPSST') end as "uniqueText",
                            coalesce(cpsst.process_step_status_type, psst.process_step_status_type) as "processStepStatusType"
                     from flow.process_step_event_work_queue_type_process_step_status_type pswqtpsst
                     left join flow.company_process_step_status_type cpsst on pswqtpsst.company_process_step_status_type_id = cpsst.id
                     left join flow.process_step_status_type psst on pswqtpsst.process_step_status_type_id = psst.id
                     where pswqtpsst.process_step_event_work_queue_type_id = pswqt.id and
                           pswqtpsst.archived is not true
                     order by psst.process_step_status_type, cpsst.process_step_status_type
                 ) processStepStatuses), '[]') AS "processStepStatuses",
                 coalesce((
                   select array_to_json(array_agg(row_to_json(eventStatuses))) from (
                     select pswqtpst.id,
                            pswqtpst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
                            pswqtpst.company_event_status_type_id as "companyEventStatusTypeId",
                            coalesce(pswqtpst.event_status_type_id, cpst.event_status_type_id) as "eventStatusTypeId",
                            case when pswqtpst.event_status_type_id is not null then true else false end as "isRoot",
                            case when pswqtpst.event_status_type_id is not null then 'Category' else 'Event Status' end as "group",
                            case when pswqtpst.event_status_type_id is not null then concat(coalesce(cpst.event_status_type, pst.event_status_type), 'EST') else concat(coalesce(cpst.event_status_type, pst.event_status_type), 'CEST') end as "uniqueText",
                            pswqtpst.archived,
                            coalesce(cpst.event_status_type, pst.event_status_type) as "eventStatusType"
                     from flow.process_step_event_work_queue_type_event_status_type pswqtpst
                     left join flow.company_event_status_type cpst on pswqtpst.company_event_status_type_id = cpst.id
                     left join flow.event_status_type pst on pswqtpst.event_status_type_id = pst.id
                     where pswqtpst.process_step_event_work_queue_type_id = pswqt.id and
                           pswqtpst.archived is not true
                     order by pst.event_status_type, cpst.event_status_type
                   ) eventStatuses), '[]') AS "eventStatuses"
              from flow.process_step_event_work_queue_type pswqt
              inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id
              inner join flow.work_queue_category wqc on wqc.id = wqt.work_queue_category_id
              where pswqt.work_queue_type_id = s.work_queue_type_id AND
                    pswqt.archived is not true
              order by wqt.work_queue_type
      ) eventWorkQueueTypes), '[]') AS "eventWorkQueueTypes"
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    left join flow.object_type ot1 on ot1.id = s.view_object_type_id
    inner join flow.user u on u.id = s.owner_id
    where s.id = :smartlistId and
          cot.company_id = :companyId and
          s.archived is not true
  """;
}
