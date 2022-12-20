package com.albatross.api.v1.flow.queries;

public class ProjectProcessStepEventQuery {

  //language=PostgreSQL
  public final static String getEventAttachmentTypes = """
        select eat.id,
               eat.event_id,
               eat.attachment_type_id,
               eat.archived,
               eat.linkable,
               eat.allow_upload,
               eat.focused,
               at.attachment_type,
               eat.display_order
        from flow.event_attachment_type eat
          inner join flow.event e on e.id = eat.event_id
          inner join flow.process_step_event pse on pse.event_id = e.id
          inner join flow.project_process_step_event ppse on ppse.process_step_event_id = pse.id AND ppse.id = :ppsEventId
          inner join flow.attachment_type at on eat.attachment_type_id = at.id
        where eat.archived is not true
        order by at.attachment_type
  """;

  //language=PostgreSQL
  public final static String insertEvent = """
    insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, company_event_status_type_id, created_by_id, save_version)
        values(:projectProcessStepId, :processStepEventId, (select initial_company_event_status_type_id from flow.process_step_event where id = :processStepEventId), :createdById, 1)
  """;

  //language=PostgreSQL
  public final static String delete = """
     update flow.project_process_step_event
        set archived = true,
            modified_by_id = :userId,
            date_modified = now()
        where id = :ppseId
  """;

  //language=PostgreSQL
  public final static String getWithStatus = """
    select ppse.id,
                 ppse.company_event_status_type_id,
                 cest.event_status_type_id,
                 cest.event_status_type
          from flow.project_process_step_event ppse
            inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
          where ppse.id = :ppseId
  """;

  //language=PostgreSQL
  public final static String getBasic = """
    select ppse.*,
                 cest.event_status_type,
                 cest.event_status_type_id,
                 cpsst2.process_step_status_type_id as root_project_process_step_status_type_id,
                 e.event_name,
                 e.resource_custom_field_id,
                 pse.event_id,
                 pse.unique_behavior_type_id
          from flow.project_process_step_event ppse
                 inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
                 inner join flow.company_process_step_status_type cpsst2 on pps.company_process_step_status_type_id = cpsst2.id
                 inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                 inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                 inner join flow.event e on pse.event_id = e.id
          where ppse.id = :id
            and ppse.archived is false
  """;

  //language=PostgreSQL
  public final static String get = """
    select ppse.*,
           concat(creator.first_name, ' ', creator.last_name) as created_by,
           cest.event_status_type,
           cest.event_status_type_id,
           cpsst2.process_step_status_type_id as root_project_process_step_status_type_id,
           case when sl.system_list_type_id = 1 then o.org_name when u.first_name is null and u.last_name is null then null else concat(u.first_name, ' ', u.last_name) end as resource,
           e.event_name,
           pps.project_id,
           pps.process_step_id,
           ps.process_step_name,
           e.resource_custom_field_id,
           e.start_time_read_only,
           e.end_time_read_only,
           e.resource_read_only,
           pse.event_id,
           pps.company_process_step_status_type_id,
           cpsst.process_step_status_type_id,
           pse.unique_behavior_type_id,
           case when (select eat.id
           from flow.event_attachment_type eat
             where eat.event_id = e.id
             and eat.archived is false
             and (eat.linkable is true or eat.allow_upload is true)
             limit 1) is null then false else true end as has_attachment_types_assigned,
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(availableResources)))
                      FROM (
                             select *
                             from flow.get_system_list_options(e.company_id::bigint,
                                                               (select company_system_list_id from flow.custom_field cf where cf.id = e.resource_custom_field_id)::bigint,
                                                               true,
                                                               (select system_list_option_ids from flow.custom_field cf where cf.id = e.resource_custom_field_id)::bigint[], ppse.resource_id::bigint)) availableResources), '[]') AS "availableResources",
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(psea)))
                      FROM (
                             SELECT psea.id,
                                    psea.action_name as "actionName",
                                    psea.require_start_time as "requireStartTime",
                                    psea.require_end_time as "requireEndTime",
                                    psea.require_resource as "requireResource",
                                    psea.process_step_event_id as "processStepEventId",
                                    psea.action_type_id as "actionTypeId",
                                    psea.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                                    psea.company_event_status_type_id as "companyEventStatusTypeId",
                                    cest.event_status_type_id as "rootEventStatusTypeId",
                                    psea.created_by_id as "createdById",
                                    psea.modified_by_id as "modifiedById",
                                    cpsst.process_step_status_type as "processStepStatusType",
                                    cpsst.process_step_status_type_id as "rootProcessStepStatusTypeId",
                                    cest.event_status_type as "eventStatusType",
                                    psea.archived,
                                    psea.always_enabled as "alwaysEnabled",
                                    psea.multiple_uses as "multipleUses",
                                    psea.hide_from_web as "hideFromWeb",
                                    psea.hide_from_mobile as "hideFromMobile",
                                    coalesce((
                                               SELECT array_to_json(array_agg(row_to_json(links)))
                                               FROM (
                                                      SELECT psal.id,
                                                             psal.archived,
                                                             psal.process_step_event_action_id as "processStepEventActionId",
                                                             psal.created_by_id as "createdById",
                                                             psal.modified_by_id as "modifiedById",
                                                             l.link,
                                                             l.url
                                                      FROM flow.process_step_event_action_link psal
                                                             inner join flow.link l on l.id = psal.link_id
                                                      WHERE psal.process_step_event_action_id = psea.id
                                                        and psal.archived is not true
                                                      order by l.link
                                                    ) links), '[]') AS "childLinks",
                                    (select ppsea.date_created
                                     from flow.project_process_step_event_action ppsea
                                     where ppsea.project_process_step_event_id = ppse.id
                                       and ppsea.process_step_event_action_id = psea.id
                                     order by ppsea.date_created desc limit 1) as "actionRunDate",
                                    (select concat(u.first_name, ' ', left(u.last_name, 1))
                                     from flow.project_process_step_event_action ppsea
                                            inner join flow."user" u on ppsea.created_by_id = u.id
                                     where ppsea.project_process_step_event_id = ppse.id
                                       and ppsea.process_step_event_action_id = psea.id
                                     order by ppsea.date_created desc limit 1) as "actionRunBy",
                                    case when
                                           (select id
                                            from flow.project_process_step_event_action ppsea
                                            where ppsea.project_process_step_event_id = ppse.id
                                              and ppsea.process_step_event_action_id = psea.id limit 1) is null
                                           then false else true end as "alreadyTriggered",
                                    coalesce((
                                               SELECT array_to_json(array_agg(row_to_json(logic)))
                                               FROM (
                                                      SELECT psl.id,
                                                             psl.archived,
                                                             psl.process_step_event_requirement_id as "processStepEventRequirementId",
                                                             psl.operation_type_id as "operationTypeId",
                                                             ot.operation_type as "operationType",
                                                             ot.operation_code as "operationCode",
                                                             psl.created_by_id as "createdById",
                                                             psl.modified_by_id as "modifiedById",
                                                             psr.requirement_nbr as "requirementNbr",
                                                             psr.immutable as "processStepRequirementImmutable",
                                                             psl.sql_order as "sqlOrder"
                                                      FROM flow.process_step_event_action_logic psl
                                                             left join flow.operation_type ot on ot.id = psl.operation_type_id
                                                             left join flow.process_step_event_requirement psr on psr.id = psl.process_step_event_requirement_id
                                                      WHERE psl.process_step_event_action_id = psea.id
                                                        and psl.archived is not true
                                                      ORDER BY psl.sql_order ) logic), '[]') AS "processStepEventLogicList",
                                    coalesce((
                                               SELECT array_to_json(array_agg(row_to_json(psearf)))
                                               FROM (
                                                      select psearf.id,
                                                             psearf.custom_field_group_assignment_id as "customFieldGroupAssignmentId",
                                                             cfga.custom_field_group_id as "customFieldGroupId",
                                                             cfga.custom_field_id as "customFieldId"
                                                      from flow.process_step_event_action_field psearf
                                                             inner join flow.custom_field_group_assignment cfga on psearf.custom_field_group_assignment_id = cfga.id
                                                      where psearf.archived is false
                                                        and psearf.required is true
                                                        and psearf.process_step_event_action_id = psea.id) psearf), '[]') AS "requiredFields",
                                    coalesce((
                                               SELECT array_to_json(array_agg(row_to_json(psearf)))
                                               FROM (
                                                      select psearf.id,
                                                             psearf.custom_field_group_assignment_id as "customFieldGroupAssignmentId",
                                                             cfga.custom_field_group_id as "customFieldGroupId",
                                                             cfga.custom_field_id as "customFieldId"
                                                      from flow.process_step_event_action_field psearf
                                                             inner join flow.custom_field_group_assignment cfga on psearf.custom_field_group_assignment_id = cfga.id
                                                      where psearf.archived is false
                                                        and psearf.required is false
                                                        and psearf.process_step_event_action_id = psea.id) psearf), '[]') AS "optionalFields"
                             FROM flow.process_step_event_action psea
                                    left join flow.company_process_step_status_type cpsst on psea.company_process_step_status_type_id = cpsst.id
                                    left join flow.company_event_status_type cest on psea.company_event_status_type_id = cest.id
                             WHERE psea.process_step_event_id = pse.id
                               AND psea.archived is not true
                               and psea.action_type_id != 3
                             order by psea.display_order) psea), '[]') AS "eventActions",
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(psea)))
                      FROM (
                             SELECT psea.id,
                                    psea.action_name as "actionName",
                                    psea.archived,
                                    psea.content,
                                    psea.color,
                                    psea.bg_color as "bgColor",
                                    psea.always_enabled as "alwaysEnabled",
                                    false as "alreadyTriggered",
                                    coalesce((
                                               SELECT array_to_json(array_agg(row_to_json(logic)))
                                               FROM (
                                                      SELECT psl.id,
                                                             psl.archived,
                                                             psl.process_step_event_requirement_id as "processStepEventRequirementId",
                                                             psl.operation_type_id as "operationTypeId",
                                                             ot.operation_type as "operationType",
                                                             ot.operation_code as "operationCode",
                                                             psl.created_by_id as "createdById",
                                                             psl.modified_by_id as "modifiedById",
                                                             psr.requirement_nbr as "requirementNbr",
                                                             psr.immutable as "processStepRequirementImmutable",
                                                             psl.sql_order as "sqlOrder"
                                                      FROM flow.process_step_event_action_logic psl
                                                             left join flow.operation_type ot on ot.id = psl.operation_type_id
                                                             left join flow.process_step_event_requirement psr on psr.id = psl.process_step_event_requirement_id
                                                      WHERE psl.process_step_event_action_id = psea.id
                                                        and psl.archived is not true
                                                      ORDER BY psl.sql_order ) logic), '[]') AS "processStepEventLogicList"
                             FROM flow.process_step_event_action psea
                             WHERE psea.process_step_event_id = pse.id
                               AND psea.archived is not true
                               and psea.action_type_id = 3
                             order by psea.display_order) psea), '[]') AS "eventBanners",
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(wlp)))
                      FROM (
                             SELECT wlp.id,
                                    wlp.position_id as "positionId",
                                    wlp.created_by_id as "createdById",
                                    wlp.modified_by_id as "modifiedById",
                                    wlp.archived
                             FROM flow.white_listed_position wlp
                             WHERE wlp.white_list_type_id = 6
                               and wlp.event_id = e.id
                               AND wlp.archived is not true) wlp), '[]') AS "startTimeWhiteListedPositions",
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(wlp)))
                      FROM (
                             SELECT wlp.id,
                                    wlp.position_id as "positionId",
                                    wlp.created_by_id as "createdById",
                                    wlp.modified_by_id as "modifiedById",
                                    wlp.archived
                             FROM flow.white_listed_position wlp
                             WHERE wlp.white_list_type_id = 7
                               and wlp.event_id = e.id
                               AND wlp.archived is not true) wlp), '[]') AS "endTimeWhiteListedPositions",
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(wlp)))
                      FROM (
                             SELECT wlp.id,
                                    wlp.position_id as "positionId",
                                    wlp.created_by_id as "createdById",
                                    wlp.modified_by_id as "modifiedById",
                                    wlp.archived
                             FROM flow.white_listed_position wlp
                             WHERE wlp.white_list_type_id = 8
                               and wlp.event_id = e.id
                               AND wlp.archived is not true) wlp), '[]') AS "resourceWhiteListedPositions"
    from flow.project_process_step_event ppse
           inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
           inner join flow.process_step ps on pps.process_step_id = ps.id
           inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
           inner join flow.company_process_step_status_type cpsst2 on pps.company_process_step_status_type_id = cpsst2.id
           inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
           inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
           inner join flow.event e on pse.event_id = e.id
           inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
           left join flow.user_position up on up.id = ppse.resource_id
           left join flow.user u on u.id = up.user_id
           left join flow.org o on o.id = ppse.resource_id
           left join flow.user creator on creator.id = ppse.created_by_id
           inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
           inner join flow.system_list sl on sl.id = csl.system_list_id
    where ppse.id = :id
      and ppse.project_process_step_id = :ppsId
      and ppse.archived is false
  """;

  //language=PostgreSQL
  public final static String savePpsEventDetails = """
        update flow.project_process_step_event
          set resource_id = :resourceId::bigint,
              start_time = :startTime::timestamp,
              end_time = :endTime::timestamp,
              company_event_status_type_id = case when :companyEventStatusTypeId::bigint is null then company_event_status_type_id else :companyEventStatusTypeId::bigint end,
              modified_by_id = :modifiedById::bigint,
              date_modified = now(),
              save_version = save_version + 1
        where id = :id
          and save_version = :saveVersion
  """;

  //language=PostgreSQL
  public final static String savePpsEventDetailsNoVersion = """
        update flow.project_process_step_event
          set resource_id = :resourceId::bigint,
              start_time = :startTime::timestamp,
              end_time = :endTime::timestamp,
              company_event_status_type_id = case when :companyEventStatusTypeId::bigint is null then company_event_status_type_id else :companyEventStatusTypeId::bigint end,
              modified_by_id = :modifiedById::bigint,
              date_modified = now()
        where id = :id
  """;

  //language=PostgreSQL
  public final static String getCompanyId = """
        select e.company_id
        from flow.project_process_step_event ppse
        inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
        inner join flow.event e on pse.event_id = e.id
        where ppse.id = :sourceId
  """;

  //language=PostgreSQL
  public final static String getProjectProcessStepEventAttachments = """
     select
            a.id,
            a.size,
            a.uuid,
            a.date_created,
            a.date_modified,
            a.filename,
            a.attachment_type_id,
            a.content_type,
            a.display_name,
            a.s3_key,
            a.archived,
            ppsa.linked,
            substring(filename, '\\.([^\\.]+)$') as file_extension,
            ps.process_step_name,
            ppsa.project_process_step_event_id,
            pps.id as "projectProcessStepId",
            concat(u.first_name, ' ', u.last_name) AS uploaded_by,
            att.attachment_type,
            orgn.*
          from flow.project_process_step_event_attachment ppsa
                 inner join flow.attachment a on a.id = ppsa.attachment_id
                 inner join flow.project_process_step_event ppse on ppse.id = ppsa.project_process_step_event_id
                 inner join flow.process_step_event pse on pse.id = ppse.process_step_event_id
                 inner join flow.event_attachment_type eat on eat.event_id = pse.event_id
                 inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
                 inner join flow.process_step ps on ps.id = pps.process_step_id
                 inner join flow."user" u ON a.created_by_id = u.id
                 inner join flow.attachment_type att on a.attachment_type_id = att.id and att.id = eat.attachment_type_id
                 left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
          where ppsa.project_process_step_event_id = :projectProcessStepEventId
            and ppsa.archived is not true
            and a.archived is not true
            and eat.archived is false
            and att.archived is false
            and case when :linked is true then ppsa.linked is true and eat.archived is false else ppsa.linked is false end
          order by ppsa.date_created desc
  """;

  //language=PostgreSQL
  public final static String linkAttachment = """
        insert into flow.project_process_step_event_attachment(attachment_id, project_process_step_event_id, created_by_id, linked)
        values(:attachmentId, :projectProcessStepEventId, :userId, true)
  """;

  //language=PostgreSQL
  public final static String unlinkAttachment = """
        update flow.project_process_step_event_attachment
          set archived = true,
              date_modified = now(),
              modified_by_id = :userId
        where attachment_id = :attachmentId
        and project_process_step_event_id = :projectProcessStepEventId
        and linked is true
  """;

  //language=PostgreSQL
  public final static String addAttachment = """
        insert into flow.project_process_step_event_attachment(attachment_id, project_process_step_event_id, created_by_id)
        values (:attachmentId, :projectProcessStepEventId, :createdById)
  """;

  //language=PostgreSQL
  public final static String updateCompanyEventStatus = """
        update flow.project_process_step_event
        set company_event_status_type_id = :companyEventStatusTypeId,
            date_modified = now(),
            modified_by_id = :userId
        where id = :projectProcessStepEventId
  """;

  //language=PostgreSQL
  public final static String updatePpsStatus = """
        update flow.project_process_step
          set company_process_step_status_type_id = :companyProcessStepStatusTypeId,
              main = :primaryFlag,
              date_modified = now(),
              modified_by_id = :userId
        where id = :ppsId
  """;

  //language=PostgreSQL
  public final static String updatePrimaryIfOnlyOne = """
    update flow.project_process_step pps
        set main = true
        from flow.company_process_step_status_type cpsst
        where pps.company_process_step_status_type_id = cpsst.id
          AND cpsst.process_step_status_type_id != 3
          and pps.project_id = :projectId
          and pps.process_step_id = :processStepId
          and pps.main is FALSE
          and pps.archived is not true
          and (select count(1)
               from flow.project_process_step pps2
               where project_id = :projectId
                 and pps2.process_step_id = :processStepId
                 and pps2.main is true
                 and pps2.archived is not true) = 0
          and (select count(1)
               from flow.project_process_step pps3
                      INNER JOIN flow.company_process_step_status_type cpsst3
                                 on pps3.company_process_step_status_type_id = cpsst3.id
               where pps3.project_id = :projectId
                 and pps3.process_step_id = :processStepId
                 AND cpsst3.process_step_status_type_id != 3
                 and pps3.main is FALSE
                 and pps3.archived is not true) = 1
  """;

  //language=PostgreSQL
  public final static String insertAuditRow = """
         insert into flow.project_process_step_event_action(project_process_step_event_id, process_step_event_action_id, created_by_id, allow_multiple_uses)
          values (:projectProcessStepEventId, :processStepEventActionId, :createdById, :allowMultipleUses)
  """;

  //language=PostgreSQL
  public final static String getPpsEventAction = """
    SELECT psea.id,
               psea.action_name as "actionName",
               psea.require_start_time as "requireStartTime",
               psea.require_end_time as "requireEndTime",
               psea.require_resource as "requireResource",
               psea.process_step_event_id as "processStepEventId",
               psea.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
               psea.company_event_status_type_id as "companyEventStatusTypeId",
               psea.created_by_id as "createdById",
               psea.modified_by_id as "modifiedById",
               psea.content,
               psea.color,
               psea.bg_color as "bgColor",
               cpsst.process_step_status_type as "processStepStatusType",
               cpsst.process_step_status_type_id as "rootProcessStepStatusTypeId",
               cest.event_status_type as "eventStatusType",
               psea.archived,
               psea.always_enabled as "alwaysEnabled",
               psea.multiple_uses as "multipleUses",
               case when
                      (select id
                       from flow.project_process_step_event_action ppsea
                       where ppsea.project_process_step_event_id = :ppsEventId
                         and ppsea.process_step_event_action_id = psea.id limit 1) is null
                      then false else true end as "alreadyTriggered",
               coalesce((
                          SELECT array_to_json(array_agg(row_to_json(logic)))
                          FROM (
                                 SELECT psl.id,
                                        psl.archived,
                                        psl.process_step_event_requirement_id as "processStepEventRequirementId",
                                        psl.operation_type_id as "operationTypeId",
                                        ot.operation_type as "operationType",
                                        ot.operation_code as "operationCode",
                                        psl.created_by_id as "createdById",
                                        psl.modified_by_id as "modifiedById",
                                        psr.requirement_nbr as "requirementNbr",
                                        psr.immutable as "processStepRequirementImmutable",
                                        psl.sql_order as "sqlOrder"
                                 FROM flow.process_step_event_action_logic psl
                                        left join flow.operation_type ot on ot.id = psl.operation_type_id
                                        left join flow.process_step_event_requirement psr on psr.id = psl.process_step_event_requirement_id
                                 WHERE psl.process_step_event_action_id = psea.id
                                   and psl.archived is not true
                                 ORDER BY psl.sql_order ) logic), '[]') AS "processStepEventLogicList",
               coalesce((
                          SELECT array_to_json(array_agg(row_to_json(fields)))
                          FROM (
                                 select pseaf.id,
                                        cf.id as "customFieldId",
                                        pseaf.process_step_event_action_id as "processStepEventActionId",
                                        cfg.group_name as "groupName",
                                        cf.field_name as "fieldName",
                                        cfga.id as "customFieldGroupAssignmentId",
                                        coalesce(pseaf.required, false) as required,
                                        coalesce(not pseaf.required, false) as optional
                                 from flow.custom_field_group_assignment cfga
                                        inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                        inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                        inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
                                        left join flow.process_step_event_action_field pseaf on cfga.id = pseaf.custom_field_group_assignment_id and pseaf.process_step_event_action_id = psea.id and pseaf.archived is false
                                 where cot.object_type_id = 6
                                   and cfga.archived is not true
                                   and cf.archived is not true
                                   and cfg.archived is not true
                                   and cfg.event_id = psea.process_step_event_id
                                 order by cfg.group_order, cfga.field_order ) fields), '[]') AS "customFields"
        FROM flow.process_step_event_action psea
               left join flow.company_process_step_status_type cpsst on psea.company_process_step_status_type_id = cpsst.id
               left join flow.company_event_status_type cest on psea.company_event_status_type_id = cest.id
        WHERE psea.id = :actionId
          AND psea.archived is not true
        order by psea.display_order
  """;

  //language=PostgreSQL
  public final static String getCancelledAssignedToPpsEvent = """
    SELECT cest.id,
                   ppse.company_event_status_type_id as "companyEventStatusTypeId",
                   ppse.archived,
                   cest.event_status_type as "eventStatusType",
                   cest.event_status_type_id as "eventStatusTypeId",
                   cest.company_id as "companyId",
                   est.event_status_type as "rootEventStatusType"
            FROM flow.project_process_step_event ppse
              inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
              inner join flow.event e on pse.event_id = e.id
              inner join flow.event_company_event_status_type ecest on e.id = ecest.event_id
              inner join flow.company_event_status_type cest on ecest.company_event_status_type_id = cest.id
              inner join flow.event_status_type est on cest.event_status_type_id = est.id
            WHERE ppse.id = :ppseId
              AND ppse.archived is not true
              and cest.archived is not true
              AND cest.event_status_type_id = 3
            order by cest.event_status_type
  """;

  //language=PostgreSQL
  public final static String setStatus = """
          update flow.project_process_step_event
          set date_modified = now(),
              modified_by_id = :userId,
              company_event_status_type_id = :companyEventStatusTypeId
          where id = :projectProcessStepEventId
  """;

  //language=PostgreSQL
  public final static String getActiveCloserAppointment = """
    select
            ppse.id,
            pps.id as project_process_step_id,
            pps.project_id,
            ppse.process_step_event_id as process_step_event_id,
            ppse.date_created,
            ps.process_step_name,
            ppse.start_time,
            ppse.end_time,
            pps.company_process_step_status_type_id,
            cpsst.process_step_status_type_id,
            coalesce(ppse.date_modified, ppse.date_created) as last_updated,
            cest.event_status_type,
            e.id as event_id,
            e.event_name,
            ppse.resource_id,
            cest.event_status_type_id,
            cest.id as company_event_status_type_id,
            case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource
          from flow.project p
                 inner join flow.project_process_step pps on pps.project_id = p.id
                 inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                 inner join flow.project_process_step_event ppse on ppse.project_process_step_id = pps.id
                 inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                 inner join flow.event e on pse.event_id = e.id
                 inner join flow.process_step ps on ps.id = pps.process_step_id
                 inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                 inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
                 left join flow.user_position up on up.id = ppse.resource_id
                 left join flow.user u on u.id = up.user_id
                 left join flow.org o on o.id = ppse.resource_id
                 inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
                 inner join flow.system_list sl on sl.id = csl.system_list_id
          where p.id = :projectId
            and pps.archived is not true
            and ppse.archived is not true
            and p.archived is not true
            and cest.id =
                (select id from flow.company_event_status_type cest2 where cest2.company_id = :companyId
                                                                 and cest2.event_status_type = 'Pending')
          order by ppse.start_time nulls last, ppse.end_time nulls last, ppse.id
  """;

  //language=PostgreSQL
  public final static String getActiveAhjInspectionWork = """
    select
            ppse.id,
            pps.id as project_process_step_id,
            pps.project_id,
            ppse.process_step_event_id as process_step_event_id,
            ppse.date_created,
            ps.process_step_name,
            ppse.start_time,
            ppse.end_time,
            pps.company_process_step_status_type_id,
            cpsst.process_step_status_type_id,
            coalesce(ppse.date_modified, ppse.date_created) as last_updated,
            cest.event_status_type,
            e.id as event_id,
            e.event_name,
            ppse.resource_id,
            cest.event_status_type_id,
            cest.id as company_event_status_type_id,
            case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource
          from flow.project p
                 inner join flow.project_process_step pps on pps.project_id = p.id
                 inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                 inner join flow.project_process_step_event ppse on ppse.project_process_step_id = pps.id
                 inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                 inner join flow.event e on pse.event_id = e.id
                 inner join flow.process_step ps on ps.id = pps.process_step_id
                 inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                 inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
                 left join flow.user_position up on up.id = ppse.resource_id
                 left join flow.user u on u.id = up.user_id
                 left join flow.org o on o.id = ppse.resource_id
                 inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
                 inner join flow.system_list sl on sl.id = csl.system_list_id
          where p.id = :projectId
            and pps.archived is not true
            and ppse.archived is not true
            and p.archived is not true
            and ppse.process_step_event_id = 39
            and cest.event_status_type_id =
                (select id from flow.company_event_status_type cest2 where cest2.company_id = :companyId
                                                                 and cest2.event_status_type = 'Active')
          order by ppse.start_time nulls last, ppse.end_time nulls last, ppse.id
  """;

  //language=PostgreSQL
  public final static String getActiveInstallation = """
    select
            ppse.id,
            pps.id as project_process_step_id,
            pps.project_id,
            ppse.process_step_event_id as process_step_event_id,
            ppse.date_created,
            ps.process_step_name,
            ppse.start_time,
            ppse.end_time,
            pps.company_process_step_status_type_id,
            cpsst.process_step_status_type_id,
            coalesce(ppse.date_modified, ppse.date_created) as last_updated,
            cest.event_status_type,
            e.id as event_id,
            e.event_name,
            ppse.resource_id,
            cest.event_status_type_id,
            cest.id as company_event_status_type_id,
            case when sl.system_list_type_id = 1 then o.org_name else concat(u.first_name, ' ', u.last_name) end as resource
          from flow.project p
                 inner join flow.project_process_step pps on pps.project_id = p.id
                 inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                 inner join flow.project_process_step_event ppse on ppse.project_process_step_id = pps.id
                 inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                 inner join flow.event e on pse.event_id = e.id
                 inner join flow.process_step ps on ps.id = pps.process_step_id
                 inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
                 inner join flow.custom_field cf on cf.id = e.resource_custom_field_id
                 left join flow.user_position up on up.id = ppse.resource_id
                 left join flow.user u on u.id = up.user_id
                 left join flow.org o on o.id = ppse.resource_id
                 inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
                 inner join flow.system_list sl on sl.id = csl.system_list_id
          where p.id = :projectId
            and pps.archived is not true
            and ppse.archived is not true
            and p.archived is not true
            and ppse.process_step_event_id = 22
            and cest.event_status_type_id =
                (select id from flow.company_event_status_type cest2 where cest2.company_id = :companyId
                                                                 and cest2.event_status_type = 'Active')
          order by ppse.start_time nulls last, ppse.end_time nulls last, ppse.id
  """;


}
