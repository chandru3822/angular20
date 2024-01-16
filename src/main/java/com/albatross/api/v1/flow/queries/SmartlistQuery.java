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
      p.position as owner_position
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    left join flow.user_position up on up.user_id = s.owner_id
    left join flow.position p on up.position_id = p.id
    where
      cot.company_id = :companyId and
      s.owner_id = :userId and
      s.archived is not true and
      s.work_queue_type_id is null and
      (:isSystemAdmin or (
        up.user_id = :userId and
        up.primary_flag is true and
        (up.end_date is null or (up.end_date is not null and up.end_date > now())) and
        up.archived is false and
        p.company_id = :companyId
      ))
    order by s.name, s.date_modified desc
    """;

  //language=PostgreSQL
  public final static String getShared = """
    -- shared to user
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
      ac.access_level
    from flow.smartlist_access_control sac
    inner join flow.smartlist s on sac.smartlist_id = s.id
    inner join flow.user_position up on sac.user_position_id = up.id
    inner join flow.position p on up.position_id = p.id
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    inner join flow.access_control ac on sac.access_control_id = ac.id
    where
      up.user_id = :userId and
      up.primary_flag is true and
      up.archived is false and
      (up.end_date is null or (up.end_date is not null and up.end_date > now())) and
      cot.company_id = :companyId and
      sac.archived is false and
      s.archived is false and
      p.company_id = :companyId
    union distinct
    -- shared to org
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
      ac.access_level
    from flow.smartlist_access_control sac
    inner join flow.smartlist s on sac.smartlist_id = s.id
    inner join flow.user_position up on sac.org_id = up.org_id
    inner join flow.position p on up.position_id = p.id
    inner join flow.org o on up.org_id = o.id
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    inner join flow.access_control ac on sac.access_control_id = ac.id
    where
      up.user_id = :userId and
      up.primary_flag is true and
      (up.end_date is null or (up.end_date is not null and up.end_date > now())) and
      up.archived is false and
      cot.company_id = :companyId and
      sac.archived is false and
      s.archived is false and
      o.archived is false and
      p.company_id = :companyId
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
      concat(u.first_name, ' ', u.last_name) "owner"
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    where
      cot.company_id = :companyId and
      s.public and
      s.archived is not true and
      s.work_queue_type_id is null
    order by s.name, s.date_modified desc
    """;

  //language=PostgreSQL
  public final static String getAll = """
    select
      distinct on (s.name, s.id) s.id,
      s.name,
      s.company_object_type_id,
      s.public,
      s.owner_id,
      s.date_created,
      s.date_modified,
      sm.date_created as date_last_exported,
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
      p.position as owner_position
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    left join flow.user_position up on up.user_id = s.owner_id
    left join flow.position p on up.position_id = p.id
    left join flow.smartlist_metrics sm on s.id = sm.smartlist_id
    where
      cot.company_id = :companyId and
      s.archived is not true and
      s.work_queue_type_id is null and
      up.primary_flag is true and
      up.archived is false and
      p.company_id = :companyId
    order by s.name, s.id, s.date_modified desc, sm.date_created desc
    """;

  //language=PostgreSQL
  public final static String getById = """
    select
      distinct on (s.id) s.id,
      s.name,
      s.company_object_type_id,
      s.public,
      s.owner_id,
      s.date_created,
      s.date_modified,
      sm.date_created as date_last_exported,
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
      p.position as owner_position,
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
      ) eventWorkQueueTypes), '[]') AS "eventWorkQueueTypes",
      coalesce((
       select array_to_json(array_agg(row_to_json(accessControl)))
       from (
         select
               sac.id,
               sac.smartlist_id as "smartlistId",
               sac.org_id as "orgId",
               sac.user_position_id as "userPositionId",
               sac.user_position_id is not null as "isUser",
               sac.org_id is not null as "isOrg",
               sac.access_control_id as "accessControlId",
               ac.access_level as "accessLevel",
               case when sac.org_id is not null then o.org_name else u.first_name || ' ' || u.last_name end as "name",
               p1.position
             from flow.smartlist_access_control sac
             inner join flow.access_control ac on sac.access_control_id = ac.id
             left join flow.user_position up1 on sac.user_position_id = up1.id
             left join flow.user u on up1.user_id = u.id
             left join flow.position p1 on up1.position_id = p1.id
             left join flow.org o on sac.org_id = o.id
             where
               sac.smartlist_id = s.id and
               sac.archived is false
      ) accessControl), '[]') AS "accessControl"
    from flow.smartlist s
    inner join flow.company_object_type cot on cot.id = s.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
    inner join flow.user u on u.id = s.owner_id
    left join flow.user_position up on up.user_id = s.owner_id and
              up.primary_flag is true and
              (up.end_date is null or (up.end_date is not null and up.end_date > now())) and
              up.archived is false
    left join flow.position p on up.position_id = p.id and p.company_id = :companyId
    left join flow.smartlist_metrics sm on s.id = sm.smartlist_id
    where s.id = :smartlistId and
          cot.company_id = :companyId and
          s.archived is not true
    order by s.id, sm.date_created desc
  """;

  //language=PostgreSQL
  public final static String add = """
    insert into flow.smartlist (name, company_object_type_id, public, owner_id, main_process_steps, project_details, primary_user_position, created_by_id, date_created, modified_by_id, date_modified)
    values (:name, :companyObjectTypeId, :public, :ownerId, :mainProcessSteps, :projectDetails, :primaryUserPosition, :createdById, now(), :createdById, now())
    returning id;
  """;

  //language=PostgreSQL
  public final static String update = """
    update flow.smartlist
    set
      name = :name,
      company_object_type_id = :companyObjectTypeId,
      public = :public,
      modified_by_id = :userId,
      date_modified = now(),
      project_details = :projectDetails,
      main_process_steps = :mainProcessSteps,
      primary_user_position = :primaryUserPosition
    where
      id = :id;
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
      up.user_id,
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
    --using smartlistId for security so users can't arbitrarily update access controls for other smartlists
    update flow.smartlist_access_control
    set
      archived = true,
      modified_by_id = :userId,
      date_modified = now()
    where
      id = :id and
      smartlist_id = :smartlistId
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
    where
      s.name = :name::text and
      cot.company_id = :companyId and
      s.archived is not true and
      s.work_queue_type_id is null
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

  //language=PostgreSQL
  public final static String addError = """
    insert into flow.smartlist_error (smartlist_id, smartlist, smartlist_fields, smartlist_requirements, stacktrace, created_by, query)
    values (:smartlistId, :smartlist::jsonb, :fields::jsonb, :requirements::jsonb, :stacktrace, :createdById, :query)
  """;

  //language=PostgreSQL
  public final static String addMetric = """
    insert into flow.smartlist_metrics (smartlist_id, smartlist, smartlist_fields, smartlist_requirements, query, execution_duration, created_by_id)
    values (:smartlistId, :smartlist::jsonb, :fields::jsonb, :requirements::jsonb, :query, :duration, :createdById)
  """;

  //language=PostgreSQL
  public final static String getMetrics = """
    select
      sm.id,
      sm.smartlist_id,
      sm.created_by_id,
      concat(u.first_name, ' ', u.last_name) as created_by,
      sm.date_created
    from flow.smartlist_metrics sm
    inner join flow.smartlist s on sm.smartlist_id = s.id
    inner join flow.company_object_type cot on s.company_object_type_id = cot.id
    inner join flow.user u on sm.created_by_id = u.id
    where
      sm.smartlist_id = :smartlistId and
      cot.company_id = :companyId
    order by sm.date_created desc
  """;

  //language=PostgreSQL
  public final static String getAvailableFields = """
    -- system fields
    select
      sf.id as "smartlistFieldId",
      sf.smartlist_system_list_id as "smartlistSystemListId",
      cot.object_type_id,
      null as "customFieldGroupAssignmentId",
      sf.name as "name",
      null as "customFieldSqlKey",
      null as "customFieldSql",
      null as "customFieldSqlSmartlist",
      null as "CompanySystemListId",
      '[]' as "systemListOptionIds",
      null as "processStepId",
      null as "processStepName",
      null as "eventId",
      null as "eventName",
      null as "processStepEventId",
      cdt.data_type_id as "dataTypeId",
      case when sf.smartlist_system_list_id is null then cdt.has_list_values else true end as "hasListValues",
      cdt.allow_multiple as "allowMultiple",
      null as "systemListTypeId",
      null as "systemListId",
      case when sf.smartlist_system_list_id is null then '[]' else
        (select to_jsonb(array_agg(row_to_json(rows))) from (
          select id, name from flow.get_smartlist_system_list_options(sf.smartlist_system_list_id::bigint, :companyId::bigint)
        ) rows)
      end as "listOfValues"
    from flow.smartlist_field sf
    inner join flow.company_object_type cot on cot.id = sf.company_object_type_id
    inner join flow.company_data_type cdt on cdt.id = sf.company_data_type_id
    where
      cot.object_type_id = any(array[ :objectTypeIds ]::bigint[]) and
      cot.company_id = :companyId and
      cot.archived is not true
    union
    -- custom fields
    select
      null as "smartlistFieldId",
      null as "smartlistSystemListId",
      cot.object_type_id,
      cfga.id as "customFieldGroupAssignmentId",
      cf.field_name as "name",
      cf.custom_field_sql_key as "customFieldSqlKey",
      cf.custom_field_sql as "customFieldSql",
      cf.custom_field_sql_smartlist as "customFieldSqlSmartlist",
      cf.company_system_list_id as "companySystemListId",
      to_jsonb(cf.system_list_option_ids) as "systemListOptionIds",
      case when cot.object_type_id = 6 then ps2.id else ps.id end as "processStepId",
      case when cot.object_type_id = 6 then ps2.process_step_name else ps.process_step_name end as "processStepName",
      e.id as "eventId",
      e.event_name as "eventName",
      pse.id as "processStepEventId",
      cdt.data_type_id as "dataTypeId",
      case when cdt.has_list_values or cf.custom_field_sql_key is not null then true else false end as "hasListValues",
      cdt.allow_multiple as "allowMultiple",
      sl.system_list_type_id  as "systemListTypeId",
      sl.id as "systemListId",
      case
        when cf.custom_field_sql_smartlist is not null then (
          select to_jsonb(array_agg(row_to_json(listOfValues)))
          from (
            select * from flow.exec_custom_field_sql(cf.custom_field_sql_smartlist)
          ) listOfValues
        )
        else coalesce((
        select to_jsonb(array_agg(row_to_json(rows))) from (
          select
            lv.id,
            lv.name,
            lv.parent_id as "parentId",
            lv.date_created as "dateCreated",
            lv.date_modified as "dateModified",
            lv.created_by_id as "createdById",
            lv.modified_by_id as "modifiedById",
            lv.display_order as "displayOrder",
            lv.archived
          from flow.list_of_value lv
          where
            lv.parent_id = cf.list_of_value_id and
            lv.archived is not true
          order by
            case when cf.sort_list_values_alphabetically is true  then lv.name end,
            case when cf.sort_list_values_alphabetically is false then lv.display_order end
      ) rows), '[]') end AS "listOfValues"
    from flow.custom_field_group_assignment cfga
    inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
    inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
    left join flow.process_step ps on ps.id = cfg.process_step_id
    left join flow.event e on e.id = cfg.event_id
    left join flow.process_step_event pse on e.id = pse.event_id
    left join flow.process_step ps2 on pse.process_step_id = ps2.id
    inner join flow.custom_field cf on cf.id = cfga.custom_field_id
    inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
    left join flow.company_system_list csl on csl.id = cf.company_system_list_id
    left join flow.system_list sl on sl.id = csl.system_list_id
    where
      cot.object_type_id = any(array[ :objectTypeIds ]::bigint[]) and
      cot.company_id = :companyId and
      cdt.data_type_id != 12 and
      cfga.ancillary_custom_field_group_assignment_id is null and
      cfga.archived is not true and
      cfg.archived is not true
    union
    -- PSs with CFGs but only ancillary fields
    select
      null as "smartlistFieldId",
      null as "smartlistSystemListId",
      cot.object_type_id,
      null as "customFieldGroupAssignmentId",
      null as "name",
      null as "customFieldSqlKey",
      null as "customFieldSql",
      null as "customFieldSqlSmartlist",
      null as "companySystemListId",
      null as "systemListOptionIds",
      ps.id as "processStepId",
      ps.process_step_name as "processStepName",
      null as "eventId",
      null as "eventName",
      null as "processStepEventId",
      null as "dataTypeId",
      null as "hasListValues",
      null as "allowMultiple",
      null as "systemListTypeId",
      null as "systemListId",
      null as "listOfValues"
    from flow.process_step ps
    inner join flow.custom_field_group cfg on cfg.process_step_id = ps.id
    inner join flow.custom_field_group_assignment cfga on cfga.custom_field_group_id = cfg.id
    inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
    where
      cfg.archived is not true and
      ps.archived is not true and
      cfga.archived is not true and
      cfga.ancillary_custom_field_group_assignment_id is not null and
      cot.company_id = :companyId and
      cot.object_type_id = 4 and
      -- include these results only if we're fetching process steps
      true = case when 4 = any(array[ :objectTypeIds ]::bigint[])then true else false end and
      not exists (
        select distinct(ps1.id)
        from  flow.custom_field_group_assignment cfga1
        inner join flow.custom_field_group cfg1 on cfg1.id = cfga1.custom_field_group_id
        inner join flow.company_object_type cot1 on cot1.id = cfg1.company_object_type_id
        inner join flow.process_step ps1 on ps1.id = cfg1.process_step_id
        where
          cot1.object_type_id = cot.object_type_id and
          cot1.company_id = :companyId and
          cfga1.ancillary_custom_field_group_assignment_id is null and
          cfga1.archived is not true and
          cfg1.archived is not true and
          ps1.id = ps.id
      )
    union
    -- PSs without CFGs
    select
      null as "smartlistFieldId",
      null as "smartlistSystemListId",
      4 as "objectTypeId",
      null as "customFieldGroupAssignmentId",
      null as "name",
      null as "customFieldSqlKey",
      null as "customFieldSql",
      null as "customFieldSqlSmartlist",
      null as "companySystemListId",
      null as "systemListOptionIds",
      ps.id as "processStepId",
      ps.process_step_name as "processStepName",
      null as "eventId",
      null as "eventName",
      null as "processStepEventId",
      null as "dataTypeId",
      null as "hasListValues",
      null as "allowMultiple",
      null as "systemListTypeId",
      null as "systemListId",
      null as "listOfValues"
    from flow.process_step ps
    inner join flow.process_step_process psp on ps.id = psp.process_step_id
    left join flow.custom_field_group cfg on ps.id = cfg.process_step_id
    where
      ps.archived is not true and
      ps.company_id = :companyId and
      -- include these results only if we're fetching process steps
      true = case when 4 = any(array[ :objectTypeIds ]::bigint[]) then true else false end and
      cfg.id is null
    union
    -- events without CFGs
    select
      null as "smartlistFieldId",
      null as "smartlistSystemListId",
      6 as "objectTypeId",
      null as "customFieldGroupAssignmentId",
      null as "name",
      null as "customFieldSqlKey",
      null as "customFieldSql",
      null as "customFieldSqlSmartlist",
      null as "companySystemListId",
      null as "systemListOptionIds",
      null as "processStepId",
      null as "processStepName",
      e.id as "eventId",
      e.event_name as "eventName",
      pse.id as "processStepEventId",
      null as "dataTypeId",
      null as "hasListValues",
      null as "allowMultiple",
      null as "systemListTypeId",
      null as "systemListId",
      null as "listOfValues"
    from flow.event e
    inner join flow.process_step_event pse on e.id = pse.event_id
    left join flow.custom_field_group cfg on cfg.event_id = e.id
    where
      pse.archived is not true and
      e.archived is not true and
      e.company_id = :companyId and
      -- include these results only if we're fetching events
      true = case when 6 = any(array[ :objectTypeIds ]::bigint[]) then true else false end and
      cfg.id is null
    order by
      name,
      "eventName",
      "processStepName"
  """;

  //language=PostgreSQL
  public final static String getAvailableProjectDetailsFields = """
    select
      distinct coalesce(pdc.second_field_to_update, pdc.field_to_update)                   as project_details_column,
      pdc.display_name                                                            as name,
      null::bigint                                                                   as process_step_event_id,
      coalesce(pdc.second_data_type_id, pdc.data_type_id) as data_type_id,
      case when cdt.has_list_values or cf.custom_field_sql_key is not null then true else false end as has_list_values,
      cf.custom_field_sql_key,
      cf.custom_field_sql,
      cf.custom_field_sql_smartlist,
      cfga.id  as "customFieldGroupAssignmentId",
      case
        when cf.custom_field_sql_smartlist is not null then (
          select to_jsonb(array_agg(row_to_json(listOfValues)))
          from (
            select * from flow.exec_custom_field_sql(cf.custom_field_sql_smartlist)
          ) listOfValues
        )
      end                                                                         as list_of_values
    from brs.project_details_config pdc
    left join flow.custom_field_group_assignment cfga on cfga.id = pdc.custom_field_group_assignment_id
    left join flow.custom_field cf on cfga.custom_field_id = cf.id
    left join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
    where (cfga.archived is not true or cfga.id is null) and
    pdc.display_name is not null and
      (coalesce(pdc.second_field_to_update, pdc.field_to_update) not like '%_resource%' or
    coalesce(pdc.second_field_to_update, pdc.field_to_update) not like '%_start_time' or
    coalesce(pdc.second_field_to_update, pdc.field_to_update) not like '%_end_time')
    union
    select distinct coalesce(pdec.second_field_to_update, pdec.field_to_update) as project_details_column,
    pdec.display_name                                           as name,
    pdec.process_step_event_id                                  as process_step_event_id,
      case
    when coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_resource%' then 6
      else 2
    end                                                         as data_type_id,
      case
    when coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_resource%' then true
    end                                                         as has_list_values,
      null                                                        as custom_field_sql_key,
      null                                                        as custom_field_sql,
      null                                                        as custom_field_sql_smartlist,
      cfga.id  as "customFieldGroupAssignmentId",

                  case
    when coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_resource%' then
      (
        select to_jsonb(array_agg(row_to_json(listOfValues)))
    from (
      select *
      from flow.get_system_list_options(3, cf.company_system_list_id, true,
      cf.system_list_option_ids)
                             ) listOfValues
                      )
    end                                                         as list_of_values
    from brs.project_detail_events_config pdec
    inner join flow.process_step_event pse on pdec.process_step_event_id = pse.id
    inner join flow.event e on pse.event_id = e.id
    inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
    left join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
    where (pse.archived is not true) and
    pdec.display_name is not null and
      (coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_resource%' or
    coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_start_time' or
    coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_end_time')
    order by name
  """;

  //language=PostgreSQL
  public final static String addField = """
    insert into flow.smartlist_field_assignment (smartlist_id, smartlist_field_id, custom_field_group_assignment_id, display_order, process_step_id, project_details_column, process_step_event_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:smartlistId, :smartlistFieldId, :customFieldGroupAssignmentId, :displayOrder, :processStepId, :projectDetailsColumn, :processStepEventId, :createdById, now(), :createdById, now())

    returning id
  """;

  //language=PostgreSQL
  public final static String deleteField = """
    update flow.smartlist_field_assignment
    set
      archived = true,
      modified_by_id = :userId,
      date_modified = now()
    where id = :id
  """;

  //language=PostgreSQL
  public final static String updateDisplayOrder = """
    update flow.smartlist_field_assignment
    set
      display_order = :displayOrder,
      modified_by_id = :userId,
      date_modified = now()
    where id = :id
  """;

  //language=PostgreSQL
  public final static String getProjectDetailsRequirements = """
    select sr.id,
    sr.display_order,
    sr.smartlist_id,
    sr.operator_type_id,
    sr.requirement_value,
    sr.secondary_requirement_value,
    sr.data_type_requirement_id,
    sr.list_of_value_id,
      case when sr.data_type_requirement_id is null then true else false end            as is_custom_value,
    opt.operator_type,
      case
    when sr.data_type_requirement_id is null then null
      else jsonb_build_object(
             'id', dtr.id,
             'dataTypeValue', dtr.data_type_value,
             'secondaryRequirement', dtr.secondary_requirement
             )
    end                                                                               as data_type_requirement,
      null                                                                              as process_step_event_id,
    coalesce(pdc.second_field_to_update, sr.project_details_column)                   as project_details_column,
    pdc.display_name                                                                  as name,
    coalesce(pdc.second_data_type_id, pdc.data_type_id) as data_type_id,
    case when cdt.has_list_values or cf.custom_field_sql_key is not null then true else false end as has_list_values,
    cf.custom_field_sql_key,
    cf.custom_field_sql,
    cf.custom_field_sql_smartlist,
    case
      when cf.custom_field_sql_smartlist is not null then (
        select to_jsonb(array_agg(row_to_json(listOfValues)))
        from (
          select * from flow.exec_custom_field_sql(cf.custom_field_sql_smartlist)
        ) listOfValues
      )
    end as available_list_of_values
    from flow.smartlist_requirement sr
    inner join (
      select distinct field_to_update, display_name, data_type_id, second_field_to_update, second_data_type_id, custom_field_group_assignment_id
      from brs.project_details_config
    ) pdc on coalesce(pdc.second_field_to_update, pdc.field_to_update) = sr.project_details_column
    inner join flow.operator_type opt on opt.id = sr.operator_type_id
    left join flow.data_type_requirement dtr on dtr.id = sr.data_type_requirement_id
    left join flow.custom_field_group_assignment cfga on cfga.id = pdc.custom_field_group_assignment_id
    left join flow.custom_field cf on cfga.custom_field_id = cf.id
    left join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
    where sr.smartlist_id = :smartlistId and
    sr.archived is not true
    union
    select sr.id,
    sr.display_order,
    sr.smartlist_id,
    sr.operator_type_id,
    sr.requirement_value,
    sr.secondary_requirement_value,
    sr.data_type_requirement_id,
    sr.list_of_value_id,
      case when sr.data_type_requirement_id is null then true else false end as is_custom_value,
    opt.operator_type,
      case
    when sr.data_type_requirement_id is null then null
      else jsonb_build_object(
             'id', dtr.id,
             'dataTypeValue', dtr.data_type_value,
             'secondaryRequirement', dtr.secondary_requirement
             )
    end                                                                    as data_type_requirement,
    pdec.process_step_event_id,
    coalesce(pdec.second_field_to_update, sr.project_details_column)       as project_details_column,
    pdec.display_name                                                      as name,
      case
    when coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_resource%' then 6
      else 2
    end                                                                    as data_type_id,
      case
    when coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_resource%' then true
    end                                                                    as has_list_values,
    null                                                                   as custom_field_sql_key,
    null as custom_field_sql,
    null as custom_field_sql_smartlist,
         case
    when coalesce(pdec.second_field_to_update, pdec.field_to_update) like '%_resource%' then
      (
        select to_jsonb(array_agg(row_to_json(listOfValues)))
    from (
      select *
      from flow.get_system_list_options(3, cf.company_system_list_id, true,
      cf.system_list_option_ids)
                    ) listOfValues
             )
    end                                                                    as available_list_of_values
    from flow.smartlist_requirement sr
    inner join (
      select distinct field_to_update, display_name, second_field_to_update, process_step_event_id
      from brs.project_detail_events_config
    ) pdec on coalesce(pdec.second_field_to_update, pdec.field_to_update) = sr.project_details_column
    inner join flow.process_step_event pse on pdec.process_step_event_id = pse.id
    inner join flow.event e on pse.event_id = e.id
    inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
    inner join flow.operator_type opt on opt.id = sr.operator_type_id
    left join flow.data_type_requirement dtr on dtr.id = sr.data_type_requirement_id
    where sr.smartlist_id = :smartlistId and
    sr.archived is not true
    order by display_order
  """;

  //language=PostgreSQL
  public final static String addRequirement = """
    insert into flow.smartlist_requirement (smartlist_id, process_step_id, custom_field_group_assignment_id, operator_type_id, requirement_value, secondary_requirement_value, data_type_requirement_id, display_order, smartlist_field_id, list_of_value_id, list_of_value_ids, system_list_option_id, custom_sql_option_id, project_details_column, process_step_event_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:smartlistId, :processStepId, :customFieldGroupAssignmentId, :operatorTypeId, :requirementValue, :secondaryRequirementValue, :dataTypeRequirementId, :displayOrder, :smartlistFieldId, :listOfValueId, array[ :listOfValueIds ]::bigint[], :systemListOptionId, :customSqlOptionId, :projectDetailsColumn, :processStepEventId, :createdById, now(), :createdById, now())
    returning id
  """;

  //language=PostgreSQL
  public final static String updateRequirement = """
    update flow.smartlist_requirement
    set
      operator_type_id = :operatorTypeId,
      requirement_value = :requirementValue,
      secondary_requirement_value = :secondaryRequirementValue,
      data_type_requirement_id = :dataTypeRequirementId,
      list_of_value_id = :listOfValueId,
      list_of_value_ids = array[ :listOfValueIds ]::bigint[],
      system_list_option_id = :systemListOptionId,
      custom_sql_option_id = :customSqlOptionId,
      modified_by_id = :modifiedById,
      date_modified = now(),
      project_details_column = :projectDetailsColumn
    where id = :id
  """;

  //language=PostgreSQL
  public final static String deleteRequirement = """
    update flow.smartlist_requirement
    set
      archived = true,
      modified_by_id = :userId,
      date_modified = now()
    where id = :id
  """;

  //language=PostgreSQL
  public final static String getSmartlistFieldsByIds = """
    select
      sf.id as "smartlistFieldId",
      sf.smartlist_system_list_id,
      cot.object_type_id,
      sf.name,
      cdt.data_type_id as "dataTypeId",
      case when sf.smartlist_system_list_id is null then cdt.has_list_values else true end as "hasListValues",
      cdt.allow_multiple,
      sf.reference_table,
      sf.reference_column,
      sf.join_table,
      sf.join_column
    from flow.smartlist_field sf
    inner join flow.company_object_type cot on cot.id = sf.company_object_type_id
    inner join flow.company_data_type cdt on cdt.id = sf.company_data_type_id
    where
      cot.company_id = :companyId and
      sf.id = any(array[ :ids ]::bigint[])
  """;

  //language=PostgreSQL
  public final static String clearFieldsAndRequirements = """
    update flow.smartlist_field_assignment
    set
      archived = true,
      date_modified = now(),
      modified_by_id = :userId
    where
      smartlist_id = :smartlistId and
      archived is not true;

    update flow.smartlist_requirement
    set
      archived = true,
      date_modified = now(),
      modified_by_id = :userId
    where
      smartlist_id = :smartlistId and
      archived is not true
  """;
}
