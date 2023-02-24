package com.albatross.api.v1.flow.queries;

public class SmartlistQuery {

  //language=PostgreSQL
  public final static String getMine = """
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public,
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
      cot.company_id,
      concat(u.first_name, ' ', u.last_name) "owner",
      concat(cb.first_name, ' ', cb.last_name) as created_by,
      concat(mb.first_name, ' ', mb.last_name) as modified_by
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    inner join flow.user cb on cb.id = s.created_by_id
    left join flow.user mb on mb.id = s.created_by_id
    where
      cot.company_id = :companyId and
      s.owner_id = :userId and
      s.archived is not true and
      s.work_queue_type_id is null
    order by s.name, s.date_modified desc
    """;

  //language=PostgreSQL
  public final static String getShared = """
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public,
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
      cot.company_id,
      concat(u.first_name, ' ', u.last_name) "owner",
      sac.access_control_id,
      ac.access_level,
      concat(cb.first_name, ' ', cb.last_name) as created_by,
      concat(mb.first_name, ' ', mb.last_name) as modified_by
    from flow.smartlist_access_control sac
    inner join flow.smartlist s on sac.smartlist_id = s.id
    inner join flow.user_position up on sac.user_position_id = up.id
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    inner join flow.user cb on cb.id = s.created_by_id
    left join flow.user mb on mb.id = s.created_by_id
    inner join flow.access_control ac on sac.access_control_id = ac.id
    where
      up.user_id = :userId and
      cot.company_id = :companyId and
      sac.archived is false and
      s.archived is false and
      up.archived is false and
      (up.end_date is null or (up.end_date is not null and up.end_date > now()))
    union distinct
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public,
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
      cot.company_id,
      concat(u.first_name, ' ', u.last_name) "owner",
      sac.access_control_id,
      ac.access_level,
      concat(cb.first_name, ' ', cb.last_name) as created_by,
      concat(mb.first_name, ' ', mb.last_name) as modified_by
    from flow.smartlist_access_control sac
    inner join flow.smartlist s on sac.smartlist_id = s.id
    inner join flow.user_position up on sac.org_id = up.org_id
    inner join flow.org o on up.org_id = o.id
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    inner join flow.user cb on cb.id = s.created_by_id
    left join flow.user mb on mb.id = s.created_by_id
    inner join flow.access_control ac on sac.access_control_id = ac.id
    where
      up.user_id = :userId and
      cot.company_id = :companyId and
      sac.archived is false and
      s.archived is false and
      up.archived is false and
      (up.end_date is null or (up.end_date is not null and up.end_date > now())) and
      o.archived is false
    order by name
  """;

  //language=PostgreSQL
  public final static String getPublic = """
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public,
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
      cot.company_id,
      concat(u.first_name, ' ', u.last_name) "owner",
      concat(cb.first_name, ' ', cb.last_name) as created_by,
      concat(mb.first_name, ' ', mb.last_name) as modified_by
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    inner join flow.user cb on cb.id = s.created_by_id
    left join flow.user mb on mb.id = s.created_by_id
    where
      cot.company_id = :companyId and
      s.owner_id != :userId and
      s.public and
      s.archived is not true and
      s.work_queue_type_id is null
    order by s.name, s.date_modified desc
    """;

  //language=PostgreSQL
  public final static String getAll = """
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public,
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
      cot.company_id,
      concat(u.first_name, ' ', u.last_name) "owner",
      concat(cb.first_name, ' ', cb.last_name) as created_by,
      concat(mb.first_name, ' ', mb.last_name) as modified_by
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    inner join flow.user cb on cb.id = s.created_by_id
    left join flow.user mb on mb.id = s.created_by_id
    where
      cot.company_id = :companyId and
      s.archived is not true and
      s.work_queue_type_id is null
    order by s.name, s.date_modified desc
    """;

  //language=PostgreSQL
  public final static String getById = """
    select
      s.id,
      s.name,
      s.company_object_type_id,
      s.public,
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
      cot.company_id,
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
    inner join flow.user u on u.id = s.owner_id
    where s.id = :smartlistId and
          cot.company_id = :companyId and
          s.archived is not true
  """;

  //language=PostgreSQL
  public final static String getAvailableAccess = """
    select
      id as "access_control_id",
      access_level
    from flow.access_control
    where id = any(array[1,2]::bigint[])
    order by display_order
  """;

  //language=PostgreSQL
  public final static String getAccessById = """
    select
      sac.id,
      sac.smartlist_id,
      sac.org_id,
      sac.user_position_id,
      sac.user_position_id is not null as "isUser",
      sac.org_id is not null as "isOrg",
      sac.access_control_id,
      ac.access_level,
      case when sac.org_id is not null then o.org_name else u.first_name || ' ' || u.last_name end as "name",
      p.position
    from flow.smartlist_access_control sac
    inner join flow.access_control ac on sac.access_control_id = ac.id
    left join flow.user_position up on sac.user_position_id = up.id
    left join flow.user u on up.user_id = u.id
    left join flow.position p on up.position_id = p.id
    left join flow.org o on sac.org_id = o.id
    where
      sac.smartlist_id = :smartlistId and
      sac.archived is false
  """;

  //language=PostgreSQL
  public final static String addAccess = """
    insert into flow.smartlist_access_control (smartlist_id, org_id, user_position_id, access_control_id, created_by_id)
    values (:smartlistId, :orgId, :userPositionId, :accessControlId, :userId)
    returning id
  """;

  //language=PostgreSQL
  public final static String updateAccess = """
    --using smartlistId for security so users can't arbitrarily update access controls for other smartlists
    update flow.smartlist_access_control
      set
        access_control_id = :accessControlId,
        modified_by_id = :userId,
        date_modified = now()
      where
        id = :id and
        smartlist_id = :smartlistId
  """;

  //language=PostgreSQL
  public final static String deleteAccess = """
    update flow.smartlist_access_control
    set
      archived = true,
      modified_by_id = :userId,
      date_modified = now()
    where
      id = :id
  """;

  //language=PostgreSQL
  public final static String updateOwner = """
    update flow.smartlist
    set
      owner_id = :newOwnerId,
      modified_by_id = :userId,
      date_modified = now()
    where
      id = :smartlistId
  """;

  //language=PostgreSQL
  public final static String create = """
    insert into flow.smartlist (name, company_object_type_id, public, owner_id, main_process_steps, project_details, primary_user_position, created_by_id, date_created, modified_by_id, date_modified)
    values (:name, :companyObjectTypeId, :public, :ownerId, :mainProcessSteps, :projectDetails, :primaryUserPosition, :createdById, now(), :createdById, now())
    returning id;
  """;

  //language=PostgreSQL
  public final static String copyAssignedFields = """
    insert into flow.smartlist_field_assignment (smartlist_id, smartlist_field_id, custom_field_group_assignment_id, display_order, process_step_id, project_details_column, created_by_id, date_created, modified_by_id, date_modified, process_step_event_id)
    select :newId, smartlist_field_id, custom_field_group_assignment_id, display_order, process_step_id, project_details_column, :userId, now(),  :userId, now(), process_step_event_id
    from flow.smartlist_field_assignment
    where smartlist_id = :oldId and archived is not true
  """;

  //language=PostgreSQL
  public final static String copyRequirements = """
    insert into flow.smartlist_requirement (smartlist_id, process_step_id, custom_field_group_assignment_id, operator_type_id, requirement_value, secondary_requirement_value, data_type_requirement_id, display_order, smartlist_field_id, list_of_value_id, list_of_value_ids, system_list_option_id, custom_sql_option_id, project_details_column, created_by_id, date_created, modified_by_id, date_modified, process_step_event_id)
    select :newId, process_step_id, custom_field_group_assignment_id, operator_type_id, requirement_value, secondary_requirement_value, data_type_requirement_id, display_order, smartlist_field_id, list_of_value_id, list_of_value_ids, system_list_option_id, custom_sql_option_id, project_details_column, :userId, now(), :userId, now(), process_step_event_id
    from flow.smartlist_requirement
    where smartlist_id = :oldId and archived is not true
  """;

  //language=PostgreSQL
  public final static String isNameUnique = """
    select case when count(1) > 0 then false else true end
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    where lower(s.name) = lower(:name::text) and
    cot.company_id = :companyId and
    s.archived is not true
  """;

  //language=PostgreSQL
  public final static String updatePublic = """
    update flow.smartlist
    set
      public = :public,
      date_modified = now(),
      modified_by_id = :userId
    where id = :smartlistId
  """;
}
