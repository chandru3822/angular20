package com.albatross.api.v1.flow.queries;

public class ProcessQuery {

  //language=PostgreSQL
  public final static String getAllForCompany = """
             select cp.id,
                    cp.process_id,
                    process.process_name,
                    cp.company_id,
                    process.created_by_id,
                    cp.archived,
                    process.parent_company_id
             from flow.company_process cp
             inner join flow.process on process.id = cp.process_id
             where company_id = :companyId
              and cp.archived is not true
             order by process.process_name
    """;

  //language=PostgreSQL
  public final static String get = """
    select p.id,
           p.process_name,
           cp.company_id,
           p.created_by_id,
           cp.archived,
           p.parent_company_id,
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(denyListPositions)))
                      FROM (
                           select dlp.id,
                                  dlp.position_id as "positionId",
                                  dlp.company_process_id as "companyProcessId",
                                  dlp.archived,
                                  dlp.deny_list_type_id as denyListTypeId,
                                  dlp.date_created as dateCreated,
                                  dlp.created_by_id as createdById,
                                  dlp.date_modified as dateModified,
                                  dlp.modified_by_id as modifiedById,
                                  dlt.deny_list_type as denyListType
                          from flow.deny_list_position dlp
           	                    left join flow.deny_list_type dlt on dlt.id = dlp.deny_list_type_id
                          where dlp.company_process_id = cp.id
                          and dlp.archived is not true
           	                )
           	                denyListPositions), '[]') AS "denyListPositions",
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(processSteps)))
                      FROM (
                           select psp.id,
                                  psp.company_process_id as "companyProcessId",
                                  psp.process_step_id as "processStepId",
                                  ps.company_id as "companyId",
                                  psp.initial_step as "initialStep",
                                  psp.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                                  cpsst.process_step_status_type as "processStepStatusType",
                                  psp.date_created as "dateCreated",
                                  psp.created_by_id as "createdById",
                                  psp.date_modified as "dateModified",
                                  psp.modified_by_id as "modifiedById",
                                  psp.archived,
                                  ps.process_step_name as "processStepName",
                                  coalesce((
                                    SELECT array_to_json(array_agg(row_to_json(owningPositions)))
                                    FROM (
                                             SELECT pspop.id,
                                                    pspop.id as "processStepProcessOwningPositionId",
                                                    pspop.process_step_process_id as "processStepProcessId",
                                                    pspop.position_id as "positionId",
                                                    pspop.archived,
                                                    p.position
                                             FROM flow.process_step_process_owning_position pspop
                                                inner join flow.position p on p.id = pspop.position_id
                                             WHERE pspop.process_step_process_id = psp.id
                                                and pspop.archived is not true
                                             order by p.position) owningPositions), '[]') AS "owningPositions"
                           from flow.process_step_process psp
                                inner join flow.process_step ps on ps.id = psp.process_step_id
                                left join flow.company_process_step_status_type cpsst on cpsst.id = psp.company_process_step_status_type_id
                           where psp.company_process_id = cp.id and psp.archived is not true
                           order by ps.process_step_name) processSteps), '[]') AS "processStepProcesses"
          from flow.company_process cp
              inner join flow.process p on p.id = cp.process_id
          where company_id = :companyId
            and process_id = :processId
          order by p.process_name
        """;

  //language=PostgreSQL
  public final static String delete = """
        update flow.process
        set archived = true, date_modified = now()
        where id = :processId
    """;

  //language=PostgreSQL
  public final static String deleteCompanyProcess = """
        update flow.company_process
        set archived = true
        where process_id = :processId
        and company_id = :companyId
    """;

  //language=PostgreSQL
  public final static String update = """
      update flow.process
        set process_name = :processName,
            date_modified = now(),
            modified_by_id = :modifiedById
      where id = :id
    """;

  //language=PostgreSQL
  public final static String insert = """
      insert into flow.process(process_name, parent_company_id, date_created, created_by_id, date_modified, modified_by_id)
        values (:processName, :parentCompanyId,  now(), :createdById,  now(), :createdById)
      returning id
    """;

  //language=PostgreSQL
  public final static String insertCompanyProcess = """
      insert into flow.company_process (company_id, process_id, status_type_id)
        values (:companyId, :processId, :statusTypeId)
    """;

  //language=PostgreSQL
  public final static String insertDenyListPosition = """
    insert into flow.deny_list_position(position_id, company_process_id, created_by_id, date_created, modified_by_id, date_modified, deny_list_type_id)
    select :positionId, :companyProcessId,  :userId, now(), :userId, now(), :denyListTypeId
    where not exists ( select id 
                        from flow.deny_list_position
                        where company_process_id = :companyProcessId
                            and position_id = :positionId
                            and deny_list_type_id = :denyListTypeId
                            and archived is not true)
    """;

  //language=PostgreSQL
  public final static String archiveAllDenyListPositionsForProcess = """
    update flow.deny_list_position
        set archived = true,
            date_modified = now(),
            modified_by_id = :userId
        where company_process_id = :companyProcessId
        and deny_list_type_id = :denyListTypeId
    """;

  //language=PostgreSQL
  public final static String archiveDenyListPositionsNoLongerUsed = """
    update flow.deny_list_position
        set archived = true,
        date_modified = now(),
        modified_by_id = :userId
    where company_process_id = :companyProcessId
    and position_id not in (:positionIdsUsed)
    and deny_list_type_id = :denyListTypeId
""";

  //language=PostgreSQL
  public final static String deleteProcessStepFromProcess = """
      update flow.process_step_process
      set archived = true,
          modified_by_id = :modifiedById,
          date_modified = now()
      where id = :processStepProcessId
    """;

  //language=PostgreSQL
  public final static String availableProcessSteps = """
      select ps.*
      from flow.process_step ps
      where ps.archived is not true
        and ps.company_id = :companyId
        and not exists (
              select process_step_id
              from flow.process_step_process psp
              where psp.process_step_id = ps.id
                and psp.company_process_id = :companyProcessId
                and archived is not true
          )
      order by ps.process_step_name
    """;

  //language=PostgreSQL
  public final static String nonAdminProcessStepsForProcess = """
      select ps.*
      from flow.process_step ps
          inner join flow.process_step_process psp on psp.process_step_id = ps.id
      where ps.archived is not true
        and ps.company_id = :companyId
        and ps.non_admin_add is true
        and psp.company_process_id = :companyProcessId
      order by ps.process_step_name
    """;

  //language=PostgreSQL
  public final static String insertProcessStepProcess = """
      insert into flow.process_step_process (company_process_id, process_step_id, created_by_id, date_created, modified_by_id, date_modified)
      values (:companyProcessId, :processStepId, :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String updateProcessStepProcess = """
      update flow.process_step_process
        set initial_step = :initialStep,
            modified_by_id = :modifiedById,
            date_modified = now(),
            company_process_step_status_type_id = :companyProcessStepStatusTypeId
      where id = :processStepProcessId
    """;

  //language=PostgreSQL
  public final static String getInitialProcessStepProcesses = """
      select psp.id,
             psp.company_process_id as "companyProcessId",
             psp.process_step_id as "processStepId",
             ps.company_id as "companyId",
             psp.initial_step as "initialStep",
             psp.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
             cpsst.process_step_status_type as "processStepStatusType",
             psp.date_created as "dateCreated",
             psp.created_by_id as "createdById",
             psp.date_modified as "dateModified",
             psp.modified_by_id as "modifiedById",
             psp.archived,
             ps.process_step_name as "processStepName"
      from flow.process_step_process psp
               inner join flow.process_step ps on ps.id = psp.process_step_id
               inner join flow.company_process_step_status_type cpsst on cpsst.id = psp.company_process_step_status_type_id
      where psp.company_process_id = :companyProcessId
        and psp.archived is not true
        and psp.initial_step is true
      order by ps.process_step_name
    """;

  //language=PostgreSQL
  public final static String insertOwningPosition = """
    insert into flow.process_step_process_owning_position (position_id, process_step_process_id, created_by_id, date_created, modified_by_id, date_modified)
    values (:positionId, :processStepProcessId, :createdById, now(), :createdById, now())
    ON CONFLICT (position_id, process_step_process_id)
      DO UPDATE
        set archived = false,
            modified_by_id = :createdById,
            date_modified = now()
    """;

  //language=PostgreSQL
  public final static String deleteOldOwningPositions = """
    update flow.process_step_process_owning_position
        set archived = true
    where process_step_process_id = :processStepProcessId
        and position_id not in (:usedPositionIds)
        and archived is false
    """;

  //language=PostgreSQL
  public final static String getOneProcessStepProcess = """
    select psp.id,
           psp.company_process_id as "companyProcessId",
           psp.process_step_id as "processStepId",
           ps.company_id as "companyId",
           psp.date_created as "dateCreated",
           psp.created_by_id as "createdById",
           psp.date_modified as "dateModified",
           psp.modified_by_id as "modifiedById",
           psp.initial_step as "initialStep",
           psp.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
           cpsst.process_step_status_type as "processStepStatusType",
           psp.archived,
           ps.process_step_name as "processStepName",
                 coalesce((
                        SELECT array_to_json(array_agg(row_to_json(owningPositions)))
                        FROM (
                                 SELECT pspop.id,
                                        pspop.id as "processStepProcessOwningPositionId",
                                        pspop.process_step_process_id as "processStepProcessId",
                                        pspop.position_id as "positionId",
                                        pspop.archived,
                                        p.position
                                 FROM flow.process_step_process_owning_position pspop
                                      inner join flow.position p on p.id = pspop.position_id
                                 WHERE pspop.process_step_process_id = psp.id
                                    and pspop.archived is not true
                                  order by p.position) owningPositions), '[]') AS "owningPositions"
          from flow.process_step_process psp
                 inner join flow.process_step ps on ps.id = psp.process_step_id
                 left join flow.company_process_step_status_type cpsst on cpsst.id = psp.company_process_step_status_type_id
          where psp.id = :id
        """;

  //language=PostgreSQL
  public final static String getOwnerPositionsByPosition = """
     SELECT pspop.id,
            pspop.id as "processStepProcessOwningPositionId",
            pspop.process_step_process_id as "processStepProcessId",
            pspop.position_id as "positionId",
            pspop.archived,
            p.position
     FROM flow.process_step_process_owning_position pspop
          inner join flow.position p on p.id = pspop.position_id
     WHERE pspop.archived is not true and pspop.position_id = :positionId
    """;

}
