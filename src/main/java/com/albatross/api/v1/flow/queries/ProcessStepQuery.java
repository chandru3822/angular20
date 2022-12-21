package com.albatross.api.v1.flow.queries;

public class ProcessStepQuery {

  //language=PostgreSQL
  public final static String getAllForCompany = """
    select ps.id,
               ps.process_step_name,
               ps.non_admin_add,
               ps.company_id,
               ps.archived,
               ps.date_created,
               ps.date_modified,
               ps.created_by_id,
               ps.modified_by_id,
               coalesce((select true
                 from flow.process_step_process psp
                 inner join flow.company_process cp on psp.company_process_id = cp.id
                 where psp.process_step_id = ps.id
                 and psp.archived is false
                 and cp.archived is false
                 limit 1
               ), false) as used_by_process,
               coalesce((
                            SELECT array_to_json(array_agg(row_to_json(workQueueTypes)))
                            FROM (
                                     SELECT pswqt.id,
                                            pswqt.work_queue_type_id as "workQueueTypeId",
                                            pswqt.process_step_id as "processStepId",
                                            wqt.work_queue_type as "workQueueType",
                                            pswqt.archived,
                                            coalesce((
                                                         SELECT array_to_json(array_agg(row_to_json(projectStatuses)))
                                                         FROM (
                                                                  SELECT pswqtpst.id,
                                                                         pswqtpst.process_step_work_queue_type_id as "processStepWorkQueueTypeId",
                                                                         pswqtpst.company_project_status_type_id as "companyProjectStatusTypeId",
                                                                         pswqtpst.archived
                                                                  FROM flow.process_step_work_queue_type_project_status_type pswqtpst
                                                                  WHERE pswqtpst.process_step_work_queue_type_id = pswqt.id AND pswqtpst.archived is not true
                                                              ) projectStatuses), '[]') AS "projectStatuses"
                                     FROM flow.process_step_work_queue_type pswqt
                                              inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id
                                     WHERE pswqt.process_step_id = ps.id AND pswqt.archived is not true
                                     order by wqt.work_queue_type
                                 ) workQueueTypes), '[]') AS "workQueueTypes"
        from flow.process_step ps
        where ps.company_id = :companyId
          and ps.archived is not true
        order by ps.process_step_name
        """;

  //language=PostgreSQL
  public final static String get = """
    select ps.id,
                 ps.process_step_name,
                 ps.non_admin_add,
                 ps.company_id,
                 ps.archived,
                 ps.date_created,
                 ps.date_modified,
                 ps.created_by_id,
                 ps.modified_by_id,
                 ps.readonly,
                 coalesce((
                        SELECT array_to_json(array_agg(row_to_json(wlp)))
                        FROM (
                                 SELECT wlp.id,
                                        wlp.position_id as "positionId",
                                        wlp.process_step_id as "processStepId",
                                        wlp.created_by_id as "createdById",
                                        wlp.modified_by_id as "modifiedById",
                                        wlp.archived
                                 FROM flow.white_listed_position wlp
                                 WHERE wlp.white_list_type_id = 9
                                   AND wlp.archived is not true
                                   and wlp.process_step_id = ps.id) wlp), '[]') AS "whiteListedPositions",
                 coalesce((
                              SELECT array_to_json(array_agg(row_to_json(links)))
                              FROM (
                                       SELECT psl.id,
                                              psl.link_id as "linkId",
                                              psl.created_by_id as "createdById",
                                              psl.modified_by_id as "modifiedById",
                                              psl.display_order as "displayOrder",
                                              l.link,
                                              l.url,
                                              psl.archived
                                       FROM flow.process_step_link psl
                                                inner join flow.link l on l.id = psl.link_id
                                       WHERE psl.process_step_id = ps.id
                                         AND psl.archived is not true
                                    order by psl.display_order ) links), '[]') AS "links",
                           coalesce((
                                        SELECT array_to_json(array_agg(row_to_json(companyProcessStepStatusTypes)))
                                        FROM (
                                                 SELECT pscpsst.id,
                                                        pscpsst.process_step_id as "processStepId",
                                                        pscpsst.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                                                        pscpsst.archived,
                                                        pscpsst.allow_non_admin_use as "allowNonAdminUse",
                                                        ps2.process_step_name as "processStepName",
                                                        cpsst.process_step_status_type as "processStepStatusType",
                                                        cpsst.process_step_status_type_id as "processStepStatusTypeId",
                                                        cpsst.company_id as "companyId",
                                                        psst.process_step_status_type as "rootProcessStepStatusType"
                                                 FROM flow.process_step_company_process_step_status_type pscpsst
                                                          inner join flow.process_step ps2 on pscpsst.process_step_id = ps2.id
                                                          inner join flow.company_process_step_status_type cpsst on pscpsst.company_process_step_status_type_id = cpsst.id
                                                          inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
                                                 WHERE pscpsst.process_step_id = ps.id AND pscpsst.archived is not true
                                                 order by cpsst.process_step_status_type) companyProcessStepStatusTypes), '[]') AS "companyProcessStepStatusTypes",
                 coalesce((
                              SELECT array_to_json(array_agg(row_to_json(cfGroups)))
                              FROM (
                                       SELECT cfg.id,
                                              cfg.group_name as "groupName",
                                              cfg.event_id as "eventId",
                                              cot.object_type_id as "objectTypeId",
                                              cot.id as "companyObjectTypeId",
                                              cfg.archived,
                                              cfg.group_order as "groupOrder",
                                              cfg.process_step_id as "processStepId",
                                              coalesce((
                                                           SELECT array_to_json(array_agg(row_to_json(customFields)))
                                                           FROM (
                                                                    SELECT cfga.id,
                                                                     cfga.custom_field_group_id as "customFieldGroupId",
                                                                     cfga.custom_field_id as "customFieldId",
                                                                     cfga.use_parent_data as "useParentData",
                                                                     cfga.id as "customFieldGroupAssignmentId",
                                                                     cfga.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                                                                     cfga.field_order as "fieldOrder",
                                                                     cfga.archived,
                                                                     cfga.read_only as "customFieldGroupAssignmentReadOnly",
                                                                     cfga.hidden as "customFieldGroupAssignmentHidden",
                                                                     cf.field_name as "fieldName",
                                                                     cf.system_readonly as "systemReadonly",
                                                                     cfg1.group_name as "groupName",
                                                                     ps.process_step_name as "processStepName",
                                                                     ot.object_type as "objectType",
                                                                    coalesce((
                                                                      SELECT array_to_json(array_agg(row_to_json(links)))
                                                                      FROM (
                                                                               SELECT wlp.id,
                                                                                        wlp.position_id as "positionId",
                                                                                        wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                                                                        wlp.created_by_id as "createdById",
                                                                                        wlp.modified_by_id as "modifiedById",
                                                                                        wlp.archived
                                                                                 FROM flow.white_listed_position wlp
                                                                                 WHERE wlp.custom_field_group_assignment_id = cfga.id
                                                                                   AND wlp.white_list_type_id = 1
                                                                                   AND wlp.archived is not true) links), '[]') AS "whiteListedPositions",
                                                                                   coalesce((
                                                            SELECT array_to_json(array_agg(row_to_json(wlp)))
                                                            FROM (
                                                                     SELECT wlp.id,
                                                                            wlp.position_id as "positionId",
                                                                            wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                                                            wlp.created_by_id as "createdById",
                                                                            wlp.modified_by_id as "modifiedById",
                                                                            wlp.archived
                                                                     FROM flow.white_listed_position wlp
                                                                     WHERE wlp.custom_field_group_assignment_id = cfga.id
                                                                       AND wlp.white_list_type_id = 2
                                                                       AND wlp.archived is not true) wlp), '[]') AS "hiddenWhiteListedPositions"
                                                              FROM flow.custom_field_group_assignment cfga
                                                                       inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                                                       inner join flow.custom_field_group cfg1 on cfg1.id = cfga.custom_field_group_id
                                                                       inner join flow.process_step ps on ps.id = cfg1.process_step_id
                                                                       inner join flow.company_object_type cot on cot.id = cfg1.company_object_type_id
                                                                       inner join flow.object_type ot on ot.id = cot.object_type_id
                                                              WHERE cfga.custom_field_group_id = cfg.id
                                                                AND cfg.archived is not true
                                                                and cfga.archived is not true
                                                                and cf.archived is not true
                                                              union all
                                                              SELECT cfga.id,
                                                                     cfga.custom_field_group_id as "customFieldGroupId",
                                                                     cfga.custom_field_id as "customFieldId",
                                                                     cfga.use_parent_data as "useParentData",
                                                                     cfga.id as "customFieldGroupAssignmentId",
                                                                     cfga.ancillary_custom_field_group_assignment_id as "ancillaryCustomFieldGroupAssignmentId",
                                                                     cfga.field_order as "fieldOrder",
                                                                     cfga.archived,
                                                                     cfga.read_only as "customFieldGroupAssignmentReadOnly",
                                                                     cfga.hidden as "customFieldGroupAssignmentHidden",
                                                                     cf.field_name as "fieldName",
                                                                     cf.system_readonly as "systemReadonly",
                                                                     cfg1.group_name as "groupName",
                                                                     ps.process_step_name as "processStepName",
                                                                     ot.object_type as "objectType",
                                                                     '[]' as whiteListedPositions,
                                                                     coalesce((
                                                            SELECT array_to_json(array_agg(row_to_json(wlp)))
                                                            FROM (
                                                                     SELECT wlp.id,
                                                                            wlp.position_id as "positionId",
                                                                            wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                                                            wlp.created_by_id as "createdById",
                                                                            wlp.modified_by_id as "modifiedById",
                                                                            wlp.archived
                                                                     FROM flow.white_listed_position wlp
                                                                     WHERE wlp.custom_field_group_assignment_id = cfga.id
                                                                       AND wlp.white_list_type_id = 2
                                                                       AND wlp.archived is not true) wlp), '[]') AS "hiddenWhiteListedPositions"
                                                              FROM flow.custom_field_group_assignment cfga
                                                                       inner join flow.custom_field_group_assignment cfga2 on cfga2.id = cfga.ancillary_custom_field_group_assignment_id
                                                                       inner join flow.custom_field cf on cf.id = cfga2.custom_field_id
                                                                       inner join flow.custom_field_group cfg1 on cfg1.id = cfga2.custom_field_group_id
                                                                       left join flow.process_step ps on ps.id = cfg1.process_step_id
                                                                       inner join flow.company_object_type cot on cot.id = cfg1.company_object_type_id
                                                                       inner join flow.object_type ot on ot.id = cot.object_type_id
                                                              WHERE cfga.custom_field_group_id = cfg.id
                                                                AND cfga.archived is not true
                                                                and cf.archived is not true
                                                              ORDER by "fieldOrder", "fieldName") customFields), '[]') AS "customFields"
                                       FROM flow.custom_field_group cfg
                                           inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
                                       WHERE cfg.process_step_id = ps.id AND cfg.archived is not true
                                       order by cfg.group_order) cfGroups), '[]') AS custom_field_groups,
                      coalesce((
                        SELECT array_to_json(array_agg(row_to_json(workQueueTypes)))
                        FROM (
                                 SELECT pswqt.id,
                                         pswqt.work_queue_type_id as "workQueueTypeId",
                                         pswqt.process_step_id as "processStepId",
                                         wqt.work_queue_type as "workQueueType",
                                         wqc.work_queue_category as "workQueueCategory",
                                         pswqt.archived,
                                        coalesce((
                                          SELECT array_to_json(array_agg(row_to_json(projectStatuses)))
                                          FROM (
                                                   SELECT pswqtpst.id,
                                                          pswqtpst.process_step_work_queue_type_id as "processStepWorkQueueTypeId",
                                                          pswqtpst.company_project_status_type_id as "companyProjectStatusTypeId",
                                                          coalesce(pswqtpst.project_status_type_id, cpst.project_status_type_id) as "projectStatusTypeId",
                                                          case when pswqtpst.project_status_type_id is not null then true else false end as "isRoot",
                                                          case when pswqtpst.project_status_type_id is not null then 'Category' else 'Project Status' end as "group",
                                                          case when pswqtpst.project_status_type_id is not null then concat(coalesce(cpst.project_status_type, pst.project_status_type), 'PST') else concat(coalesce(cpst.project_status_type, pst.project_status_type), 'CPST') end as "uniqueText",
                                                          pswqtpst.archived,
                                                          coalesce(cpst.project_status_type, pst.project_status_type) as "projectStatusType"
                                                   FROM flow.process_step_work_queue_type_project_status_type pswqtpst
                                                    left join flow.company_project_status_type cpst on pswqtpst.company_project_status_type_id = cpst.id
                                                    left join flow.project_status_type pst on pswqtpst.project_status_type_id = pst.id
                                                   WHERE pswqtpst.process_step_work_queue_type_id = pswqt.id AND pswqtpst.archived is not true
                                                   order by pst.project_status_type, cpst.project_status_type
                                               ) projectStatuses), '[]') AS "projectStatuses",
                                               coalesce((
                        SELECT array_to_json(array_agg(row_to_json(processStepStatuses)))
                        FROM (
                                 SELECT pswqtpsst.id,
                                   pswqtpsst.process_step_work_queue_type_id as "processStepWorkQueueTypeId",
                                   pswqtpsst.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                                   coalesce(pswqtpsst.process_step_status_type_id, cpsst.process_step_status_type_id) as "processStepStatusTypeId",
                                   pswqtpsst.archived,
                                   case when pswqtpsst.process_step_status_type_id is not null then true else false end as "isRoot",
                                   case when pswqtpsst.process_step_status_type_id is not null then 'Category' else 'Process Step Status' end as "group",
                                   case when pswqtpsst.process_step_status_type_id is not null then concat(coalesce(cpsst.process_step_status_type, psst.process_step_status_type), 'PSST') else concat(coalesce(cpsst.process_step_status_type, psst.process_step_status_type), 'CPSST') end as "uniqueText",
                                   coalesce(cpsst.process_step_status_type, psst.process_step_status_type) as "processStepStatusType"
                                 FROM flow.process_step_work_queue_type_process_step_status_type pswqtpsst
                                          left join flow.company_process_step_status_type cpsst on pswqtpsst.company_process_step_status_type_id = cpsst.id
                                          left join flow.process_step_status_type psst on pswqtpsst.process_step_status_type_id = psst.id
                                 WHERE pswqtpsst.process_step_work_queue_type_id = pswqt.id AND pswqtpsst.archived is not true
                                 order by psst.process_step_status_type, cpsst.process_step_status_type
                             ) processStepStatuses), '[]') AS "processStepStatuses"
                                  FROM flow.process_step_work_queue_type pswqt
                                    inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id
                                    inner join flow.work_queue_category wqc on wqc.id = wqt.work_queue_category_id
                                  WHERE pswqt.process_step_id = ps.id AND pswqt.archived is not true
                                  order by wqt.work_queue_type
                                  ) workQueueTypes), '[]') AS "workQueueTypes"
          from flow.process_step ps
          where ps.id = :id
            and ps.archived is false
            and ps.company_id = :companyId
        """;

  //language=PostgreSQL
  public final static String saveReadOnly = """
    update flow.process_step
         set readonly = :readOnly,
             modified_by_id = :userId,
             date_modified = now()
         where id = :psId
       """;

  //language=PostgreSQL
  public final static String archiveWhiteListPositions = """
    update flow.white_listed_position
         set archived = true,
             date_modified = now(),
             modified_by_id = :userId
       where process_step_id = :psId
         and company_id = :companyId
         and white_list_type_id = :whiteListTypeId
       """;

  //language=PostgreSQL
  public final static String insertWhiteListPosition = """
    insert into flow.white_listed_position(position_id, process_step_id, white_list_type_id, company_id, created_by_id, date_created, modified_by_id, date_modified)
        select :positionId, :psId, :whiteListTypeId, :companyId, :userId, now(), :userId, now()
        where not exists (  select id
                            from flow.white_listed_position
                            where process_step_id = :psId
                              and position_id = :positionId
                              and company_id = :companyId
                              and white_list_type_id = :whiteListTypeId
                               and archived is not true)
        """;

  //language=PostgreSQL
  public final static String archiveWhiteListPositionsNoLongerUsed = """
    update flow.white_listed_position
          set archived = true,
              date_modified = now(),
              modified_by_id = :userId
        where process_step_id = :psId
          and position_id not in (:positionIdsUsed)
          and company_id = :companyId
          and white_list_type_id = :whiteListTypeId
        """;

  //language=PostgreSQL
  public final static String delete = """
    update flow.process_step
          set archived = true,
              modified_by_id = :modifiedById,
              date_modified = now()
          where id = :processStepId
        """;

  //language=PostgreSQL
  public final static String update = """
    update flow.process_step
         set modified_by_id = :modifiedById,
             date_modified = now(),
             process_step_name = :name,
             non_admin_add = :nonAdminAdd
         where id = :id
       """;

  //language=PostgreSQL
  public final static String insert = """
    insert into flow.process_step (company_id, process_step_name, non_admin_add, created_by_id, date_created, modified_by_id, date_modified)
            values (:companyId, :name, :nonAdminAdd, :createdById, now(), :createdById, now())
        """;

  //language=PostgreSQL
  public final static String getParentObjects = """
    select *
        from flow.process_step
        where company_id = :companyId
          and archived is not true
        order by process_step_name
        """;

  //language=PostgreSQL
  public final static String getParentObjectsIncludingTypes = """
    select ps.id,
               4 as object_type_id,
               ps.process_step_name as name,
               true as is_process_step
        from flow.process_step ps
        where ps.company_id = :companyId
          and ps.archived is not true
        union all
        select ot.id,
               ot.id as object_type_id,
               ot.object_type as name,
               false as is_process_step
        from flow.company_object_type cot
               inner join flow.object_type ot on ot.id = cot.object_type_id
        where cot.company_id = :companyId
          and (ot.flow_type_id = 1 OR ot.flow_type_id = 3)
          and cot.archived is not true
        order by name
        """;

  //language=PostgreSQL
  public final static String getProcessStepProcessByCompanyId = """
    select
        ps.id,
        ps.company_id,
        ps.process_step_name,
        ps.date_created,
        ps.date_modified,
        ps.created_by_id,
        ps.modified_by_id,
        ps.archived
      from flow.process_step_process psp
      inner join flow.process_step ps on ps.id = psp.process_step_id
      where ps.company_id = :companyId
        and psp.archived is not true
      order by ps.process_step_name
        """;

  //language=PostgreSQL
  public final static String getOwners = """
    select * from flow.get_process_step_available_owners(:id::bigint, :companyId::bigint, :inParentCompany)
        """;

}
