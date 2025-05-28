package com.albatross.api.v1.flow.queries;

public class ProjectProcessStepQuery {

  //language=PostgreSQL
  public final static String insertProjectProcessStep = """
    select insert_project_process_step as id from flow.insert_project_process_step(:projectId::bigint, :processStepId::bigint, :userPositionId::bigint, :userId::bigint, :companyId::bigint, :parentProjectProcessStepId::bigint, :initialCompanyProcessStepStatusTypeId::bigint, :existingCompanyProcessStepStatusTypeId::bigint, null::bigint)
  """;

  //language=PostgreSQL
  public final static String delete = """
    select from flow.delete_project_process_step(:projectProcessStepId);
  """;

  //language=PostgreSQL
  public final static String getHistory = """
    select ppsa.*,
           owner.first_name || ' ' || owner.last_name as owner,
           created_by.first_name || ' ' || created_by.last_name as created_by,
           modified_by.first_name || ' ' || modified_by.last_name as modified_by,
           ppsa.company_process_step_status_type_id,
           cpsst.process_step_status_type as company_process_step_status_type,
           cpsst.process_step_status_type_id,
           psst.process_step_status_type
    from flow.project_process_step_audit ppsa
      inner join flow.company_process_step_status_type cpsst on ppsa.company_process_step_status_type_id = cpsst.id
      inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    left join flow.user_position up on ppsa.user_position_id = up.id
    left join flow."user" owner on up.user_id = owner.id
    inner join flow."user" created_by on created_by.id = ppsa.created_by_id
    left join flow."user" modified_by on modified_by.id = ppsa.modified_by_id
    where ppsa.project_process_step_id = :projectProcessStepId
    order by date_modified nulls first
  """;

  //language=PostgreSQL
  public final static String findLatestCompletedStepByType = """
  select pps.id as project_process_step_id, pps.* from flow.project_process_step pps
  inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
  where pps.project_id = :projectId
  and pps.process_step_id = :processStepId
  and cpsst.process_step_status_type_id = :statusId
  and pps.id != :projectProcessStepId
  order by pps.id desc limit 1
""";

  //language=PostgreSQL
  public final static String updateProjectProcessStepStatusDirect = """
  UPDATE flow.project_process_step
  SET company_process_step_status_type_id = :cpsst_id,
      modified_by_id = :user_id,
      date_modified = now()
  WHERE id = :pps_id
""";

  //language=PostgreSQL
  public final static String insertProjectProcessStepAuditDirect = """
  INSERT INTO flow.project_process_step_audit
  (project_process_step_id, company_process_step_status_type_id, created_by_id, date_created)
  VALUES (:pps_id, :cpsst_id, :user_id, now())
""";

  //language=PostgreSQL
  public final static String getProjectProcessStep = """
    select * from flow.get_pps_with_actions_and_requirements(:stepId::bigint, :companyId::bigint)
  """;

  public final static String getProjectProcessStepActionButtonLogicList = """
      SELECT COALESCE((
        SELECT json_agg(logic)
        FROM (
          SELECT
            psl.id,
            psl.archived,
            psl.process_step_requirement_id as "processStepRequirementId",
            psl.operation_type_id as "operationTypeId",
            ot.operation_type as "operationType",
            ot.id as "operationTypeId",
            ot.operation_code as "operationCode",
            psl.created_by_id as "createdById",
            psl.modified_by_id as "modifiedById",
            psr.requirement_nbr as "requirementNbr",
            psr.immutable as "processStepRequirementImmutable",
            psr.process_step_requirement_type_id as "processStepRequirementTypeId",
            psrt.process_step_requirement_type as "processStepRequirementType",
            psl.sql_order as "sqlOrder",
            opt.operator_type as "operatorType",
            psr.requirement_value as "requirementValue",
            psr.secondary_requirement_value as "secondaryRequirementValue",
            dvfc.display_name as "dataViewFieldName",
            dvcfc.display_name as "dataViewChildFieldName",
            ps.process_step_name as "parentName",
            rps.process_step_name as "referenceProcessStepName",
            cf.field_name as "fieldName",
            cfn.company_function_name as "companyFunctionName",
            (
              SELECT json_build_object(
                'id', dtr.id,
                'dataTypeValue', dtr.data_type_value,
                'secondaryRequirement', dtr.secondary_requirement
              )
            ) AS "dataTypeRequirement",
            (
              SELECT CASE
                WHEN lov.id IS NOT NULL THEN json_build_object(
                  'id', lov.id,
                  'name', lov.name
                )
                ELSE '{}'
              END
            ) AS "listOfValue",
            CASE
              WHEN psr.process_step_requirement_type_id = 7 THEN COALESCE((
                SELECT json_agg(lov)
                FROM (
                  SELECT
                    pscpsst.company_process_step_status_type_id AS id,
                    CONCAT(cpsst.process_step_status_type, ' (', psst.process_step_status_type, ')') AS name
                  FROM flow.process_step_company_process_step_status_type pscpsst
                  JOIN flow.company_process_step_status_type cpsst ON pscpsst.company_process_step_status_type_id = cpsst.id
                  JOIN flow.process_step_status_type psst ON psst.id = cpsst.process_step_status_type_id
                  WHERE pscpsst.process_step_id = psr.reference_process_step_id
                    AND pscpsst.archived IS NOT TRUE
                    AND cpsst.id = ANY(psr.list_of_value_ids)
                ) lov), '[]')
              WHEN psr.process_step_requirement_type_id = 8 THEN COALESCE((
                SELECT json_agg(lov)
                FROM (
                  SELECT DISTINCT
                    psst.id,
                    psst.process_step_status_type AS name
                  FROM flow.process_step_company_process_step_status_type pscpsst
                  JOIN flow.company_process_step_status_type cpsst ON pscpsst.company_process_step_status_type_id = cpsst.id
                  JOIN flow.process_step_status_type psst ON psst.id = cpsst.process_step_status_type_id
                  WHERE pscpsst.process_step_id = psr.reference_process_step_id
                    AND pscpsst.archived IS NOT TRUE
                    AND cpsst.id = ANY(psr.list_of_value_ids)
                ) lov), '[]')
              WHEN psr.process_step_requirement_type_id = 9 THEN COALESCE((
                SELECT json_agg(lov)
                FROM (
                  SELECT
                    cpst.id,
                    CONCAT(cpst.project_status_type, ' (', pst.project_status_type, ')') AS name
                  FROM flow.company_project_status_type cpst
                  JOIN flow.project_status_type pst ON pst.id = cpst.project_status_type_id
                  WHERE cpst.archived IS NOT TRUE
                    AND cpst.id = ANY(psr.list_of_value_ids)
                ) lov), '[]')

              WHEN psr.process_step_requirement_type_id = 10 THEN COALESCE((
                SELECT json_agg(lov)
                FROM (
                  SELECT
                    pst.id,
                    pst.project_status_type AS name
                  FROM flow.project_status_type pst
                  WHERE pst.archived IS NOT TRUE
                    AND pst.id = ANY(psr.list_of_value_ids)
                ) lov), '[]')
              ELSE COALESCE((
                SELECT json_agg(lov)
                FROM (
                  SELECT
                    lv.id,
                    lv.name
                  FROM flow.list_of_value lv
                  WHERE lv.id = ANY(psr.list_of_value_ids)
                ) lov), '[]')
            END AS "listOfValues"

          FROM flow.process_step_action_logic psl
          LEFT JOIN flow.operation_type ot ON ot.id = psl.operation_type_id
          LEFT JOIN flow.process_step_requirement psr ON psr.id = psl.process_step_requirement_id
          LEFT JOIN flow.process_step_requirement_type psrt ON psr.process_step_requirement_type_id = psrt.id
          LEFT JOIN flow.operator_type opt ON opt.id = psr.operator_type_id
          LEFT JOIN flow.data_view_field_config dvfc ON dvfc.id = psr.data_view_field_config_id
          LEFT JOIN flow.data_view_child_field_config dvcfc ON dvfc.id = psr.data_view_child_field_config_id
          LEFT JOIN flow.custom_field_group_assignment cfga ON cfga.id = psr.custom_field_group_assignment_id
          LEFT JOIN flow.custom_field cf ON cf.id = cfga.custom_field_id
          LEFT JOIN flow.company_data_type cdt ON cdt.id = cf.company_data_type_id
          LEFT JOIN flow.custom_field_group cfg ON cfg.id = cfga.custom_field_group_id
          LEFT JOIN flow.process_step ps ON ps.id = cfg.process_step_id
          LEFT JOIN flow.process_step rps ON rps.id = psr.reference_process_step_id
          LEFT JOIN flow.company_function cfn ON cfn.id = psr.company_function_id
          LEFT JOIN flow.db_function df ON df.id = cfn.db_function_id
          LEFT JOIN flow.data_type_requirement dtr ON dtr.id = psr.data_type_requirement_id
          LEFT JOIN flow.list_of_value lov ON lov.id = psr.list_of_value_id

          WHERE psl.process_step_action_id = :process_step_action_id
            AND psl.archived IS NOT TRUE

          ORDER BY psl.sql_order
        ) logic
      ), '[]')
    """;

  //language=PostgreSQL
  public final static String getPPSForAutotrigger = """
      select * from flow.get_pps_for_autotrigger(:ppsId::bigint, :companyId::bigint)
  """;

  //language=PostgreSQL
    public final static String getOneCustomFieldValue = """
select * from flow.get_one_cfv(:objectTypeId::bigint, :cfgaId::bigint, :primaryId::bigint)
""";

  //language=PostgreSQL
  public final static String getStatus = """
      select pps.id as project_process_step_id,
             pps.company_process_step_status_type_id,
             cpsst.process_step_status_type as company_process_step_status_type,
             cpsst.process_step_status_type_id,
             psst.process_step_status_type
      from flow.project_process_step pps
        inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
        inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
      where pps.id = :stepId
  """;

  //language=PostgreSQL
  public final static String getProjectProcessStepAttachments = """
    select
          a.id,
          a.size,
          a.uuid,
          a.date_created,
          a.date_modified,
          a.filename,
          a.display_name,
          a.attachment_type_id,
          a.content_type,
          a.s3_key,
          a.archived,
          substring(filename, '\\.([^\\.]+)$') as file_extension,
          ps.process_step_name,
          ppsa.linked,
          ppsa.project_process_step_id,
          concat(u.first_name, ' ', u.last_name) AS uploaded_by,
          att.attachment_type,
          orgn.*
        from flow.project_process_step_attachment ppsa
               inner join flow.attachment a on a.id = ppsa.attachment_id
               inner join flow.attachment_type att on a.attachment_type_id = att.id
               inner join flow.project_process_step pps on pps.id = ppsa.project_process_step_id
               inner join flow.process_step ps on ps.id = pps.process_step_id
               inner join flow.process_step_attachment_type psat on psat.process_step_id = pps.process_step_id and psat.attachment_type_id = att.id
               inner join flow."user" u ON a.created_by_id = u.id
               left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
        where ppsa.project_process_step_id = :projectProcessStepId
          and a.archived is not true
          and att.archived is false
          and psat.archived is false
          and ppsa.archived is not true
          and case when :linked is true then ppsa.linked is true and psat.linkable is true else ppsa.linked is false end
        order by pps.date_created desc
  """;

  //language=PostgreSQL
  public final static String getStepAttachmentTypes = """
    select psat.id,
               psat.process_step_id,
               psat.attachment_type_id,
               psat.archived,
               psat.linkable,
               psat.allow_upload,
               psat.focused,
               at.attachment_type,
               psat.display_order
        from flow.process_step_attachment_type psat
          inner join flow.project_process_step pps on pps.process_step_id = psat.process_step_id AND pps.id = :ppsId
               inner join flow.attachment_type at on psat.attachment_type_id = at.id
        where psat.archived is not true
        order by at.attachment_type
  """;

  //language=PostgreSQL
  public final static String linkAttachment = """
    insert into flow.project_process_step_attachment(attachment_id, project_process_step_id, created_by_id, linked)
    values(:attachmentId, :projectProcessStepId, :userId, true)
  """;

  //language=PostgreSQL
  public final static String unlinkAttachment = """
    update flow.project_process_step_attachment
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where attachment_id = :attachmentId
    and project_process_step_id = :projectProcessStepId
    and linked is true
  """;

  //language=PostgreSQL
  public final static String addAttachment = """
    insert into flow.project_process_step_attachment(attachment_id, project_process_step_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:attachmentId, :projectProcessStepId, :createdById, now(), :createdById, now())
  """;

  //language=PostgreSQL
  public final static String removeOwner = """
    update flow.project_process_step
    set user_position_id = null,
        date_modified = now(),
        modified_by_id = :userId
    where id = :projectProcessStepId
  """;

  //language=PostgreSQL
  public final static String setStatus = """
    select from flow.update_project_process_step_status(:projectId::bigint, :processStepId::bigint, :projectProcessStepId::bigint, :companyProcessStepStatusTypeId::bigint, :processStepStatusTypeId::bigint, :userId::bigint, :cancelledStatusTypeId::bigint)
  """;

  //language=PostgreSQL
  public final static String setMain = """
    select from flow.set_main_project_process_step(:ppsId::bigint, :activeCompanyProcessStepStatusTypeId::bigint, :cancelledCompanyProcessStepStatusTypeId::bigint, :userId::bigint)
  """;

  //language=PostgreSQL
  public final static String getOwners = """
    with positions as (
          select array(
            select pspop.position_id
            from flow.process_step_process_owning_position pspop
            where pspop.process_step_process_id = :processStepProcessId and
                  pspop.archived is not true
          ) as position_ids
        )
        select
          u.id as user_id,
          u.first_name,
          u.last_name,
          concat(u.first_name, ' ', u.last_name) AS full_name,
          up.id as user_position_id,
          p.position
        from positions
        inner join flow.user_position up on up.position_id = any( positions.position_ids)
        inner join flow.user u on u.id = up.user_id
        inner join flow.position p on p.id = up.position_id
        inner join flow.user_status_type ust on ust.company_id = p.company_id
        inner join flow.company_user_status cus on cus.user_id = u.id and cus.user_status_type_id = ust.id

        where
          ust.has_access is true and
          up.archived is false and
          up.start_date <= now() and
          (up.end_date is null or up.end_date >= now()) and
          p.archived is not true
        order by u.last_name, u.first_name
  """;

  //language=PostgreSQL
  public final static String updateOwner = """
    update flow.project_process_step
    set
      user_position_id = :userPositionId,
      modified_by_id = :userId,
      date_modified = now()
    where id = :projectProcessStepId
  """;

  //language=PostgreSQL
  public final static String getOwner = """
    select user_position_id
    from flow.project_process_step
    where id = :projectProcessStepId
  """;

  //language=PostgreSQL
  public final static String getPrimaryByProjectId = """
  select pps.*
  from flow.project_process_step pps
  inner join flow.company_process_step_status_type cppsst on cppsst.id = pps.company_process_step_status_type_id
  where
      pps.project_id = :projectId and
      cppsst.process_step_status_type_id = 1 and
      pps.main is true and
    pps.archived is not true
  """;

  //language=PostgreSQL
  public final static String getPrimaryByReferenceProcessStepAndStatus = """
    select pps.*,
           cpsst.process_step_status_type_id
    from flow.project_process_step pps
             inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
    where pps.project_id = (select pps2.project_id from flow.project_process_step pps2 where pps2.id = :ppsId)
        and pps.main is true
        and pps.archived is not true
        and pps.process_step_id = :referenceProcessStepId
  """;

  //language=PostgreSQL
  public final static String insertPerformedAction = """
    insert into flow.project_process_step_action (project_process_step_id, process_step_action_id, triggered_automatically, created_by_id, allow_multiple_uses)
    values (:ppsId, :psaId, :autoTriggered, :createdById, :allowMultipleUses)
  """;

  //language=PostgreSQL
  public final static String getIdsByAutoTriggerActionsAndReqs = """
    with projects as (
        select array_agg(p.id) as ids
        from flow.project p
        inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
        where
            case when :contactId::bigint is not null then p.contact_id = :contactId else p.contact_id = 0 end and
            cpst.project_status_type_id = 1
    )
    select distinct pps.id
    from projects, flow.project_process_step pps
    inner join flow.process_step ps on ps.id = pps.process_step_id
    inner join flow.process_step_action psa on psa.process_step_id = ps.id
    inner join flow.process_step_requirement psr on psr.process_step_id = ps.id
    inner join flow.custom_field_group_assignment cfga on cfga.id = psr.custom_field_group_assignment_id
    inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
    where
        case when :contactId::bigint is not null
            then pps.project_id = any(projects.ids)
            else pps.project_id = :projectId
        end and
        pps.archived is not true and
        cpsst.process_step_status_type_id = 1 and
        pps.main is true and
        psr.custom_field_group_assignment_id in (:cfgaIds) and
        psr.archived is not true and
        psa.archived is not true and
        psa.trigger_automatically is true
  """;

  //language=PostgreSQL
  public final static String getTimeBasedAutoTriggerPps = """
    select distinct pps.id as ppsId, ps.company_id as companyId, pps.date_modified
    from flow.project_process_step pps
    inner join flow.project p on p.id = pps.project_id
    inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
    inner join flow.process_step ps on ps.id = pps.process_step_id
    inner join flow.process_step_action psa on psa.process_step_id = ps.id
    inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
    left join flow.project_process_step_action ppsa on ppsa.project_process_step_id = pps.id and ppsa.process_step_action_id = psa.id
    where cpsst.process_step_status_type_id = 1 and
          cpst.project_status_type_id = 1 and
          ppsa.id is null and
          pps.main is true and
          pps.archived is not true and
          ps.archived is not true and
          p.archived is not true and
          psa.archived is not true and
          psa.trigger_automatically is true and
          psa.time_based_trigger is true and
          case when psa.date_created >= (now() - interval '1 days') or  psa.date_modified >= (now() - interval '1 days') then true
          when
              (pps.date_modified > (now() - interval '7 days') or p.date_modified > (now() - interval '7 days')) then true else false end
    order by pps.date_modified desc, pps.id
  """;

  //language=PostgreSQL
  public final static String getInitialAutoTriggerPps = """
    select distinct pps.id as ppsId, ps.company_id as companyId
    from flow.project_process_step pps
    inner join flow.project p on p.id = pps.project_id
    inner join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
    inner join flow.process_step ps on ps.id = pps.process_step_id
    inner join flow.process_step_action psa on psa.process_step_id = ps.id
    inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
    left join flow.project_process_step_action ppsa on ppsa.project_process_step_id = pps.id and ppsa.process_step_action_id = psa.id
    where cpsst.process_step_status_type_id = 1 and
          cpst.project_status_type_id = 1 and
          ppsa.id is null and
          pps.main is true and
          pps.archived is not true and
          ps.archived is not true and
          psa.archived is not true and
          psa.trigger_automatically is true
  """;

  //language=PostgreSQL
  public final static String getCompanyId = """
        select ps.company_id
        from flow.project_process_step pps
            inner join flow.process_step ps on pps.process_step_id = ps.id
        where pps.id = :projectProcessStepId
  """;

  //language=PostgreSQL
  public final static String getUsingStatusByPpsIds = """
        select distinct pps_usage.id as project_process_step_id,
                        cpsst.process_step_status_type_id,
                        pps_src.process_step_id
        from flow.project_process_step pps_src
                 inner join flow.process_step_requirement psr on psr.reference_process_step_id = pps_src.process_step_id and psr.archived is not true
                 inner join flow.process_step_action_logic psl on psr.id = psl.process_step_requirement_id and psl.archived is not true
                 inner join flow.process_step_action psa on psl.process_step_action_id = psa.id
                 inner join flow.project_process_step pps_usage on pps_usage.process_step_id = psa.process_step_id and pps_usage.project_id = pps_src.project_id and pps_usage.archived is not true
                 inner join flow.company_process_step_status_type cpsst on pps_usage.company_process_step_status_type_id = cpsst.id
        where pps_src.id = any(array[ :projectProcessStepIds ]::bigint[])
          and pps_src.archived is not true and pps_src.process_step_id != pps_usage.process_step_id
  """;
}
