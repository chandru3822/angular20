package com.albatross.api.v1.flow.queries;

public class WorkQueueTypeQuery {

  //language=PostgreSQL
  public final static String getTypesForCompany = """
    select wqt.id,
         wqt.company_id,
         wqt.work_queue_type,
         wqt.use_event_data,
         wqt.archived,
         wqt.work_queue_category_id,
         wqc.work_queue_category,
         wqt.display_order,
         wqc.display_order as work_queue_category_display_order,
         wqt.short_window,
         wqt.short_window_duration_type_id,
         (select duration_type from flow.duration_type dt where dt.id = wqt.short_window_duration_type_id) as short_window_duration_type,
         wqt.long_window,
         wqt.long_window_duration_type_id,
         (select duration_type from flow.duration_type dt where dt.id = wqt.short_window_duration_type_id) as long_window_duration_type,
         wqt.expected_cycle,
         wqt.expected_cycle_duration_type_id,
         (select duration_type from flow.duration_type dt where dt.id = wqt.short_window_duration_type_id) as expected_cycle_duration_type,
         expected_target,
         inverse_expectation
       from flow.work_queue_type wqt
         inner join flow.work_queue_category wqc on wqc.id = wqt.work_queue_category_id
       where wqt.company_id = :companyId
         and wqt.archived is not true
       """;

  //language=PostgreSQL
  public final static String getItemsUsingType = """
    SELECT array_to_json(array_agg(row_to_json(results)))
        FROM (select ps.id as "primaryId",
               null::int as "secondaryId",
               concat('Process Step: ', ps.process_step_name) as name,
               false as "isEvent"
        from flow.process_step_work_queue_type pswqt
          inner join flow.process_step ps on ps.id = pswqt.process_step_id and ps.archived is not true
        where pswqt.work_queue_type_id = :wqtId
        and pswqt.archived is not true
        union
        select ps.id as "primaryId",
               pse.id as "secondaryId",
               concat('Event - ', ps.process_step_name, ': ', e.event_name) as name,
               true as "isEvent"
        from flow.process_step_event_work_queue_type psewqt
          inner join flow.process_step_event pse on pse.id = psewqt.process_step_event_id and pse.archived is not true
          inner join flow.process_step ps on ps.id = pse.process_step_id and ps.archived is not true
          inner join flow.event e on e.id = pse.event_id
        where psewqt.work_queue_type_id = :wqtId
          and psewqt.archived is not true
          order by name ) as results
        """;

  //language=PostgreSQL
  public final static String getDurationTypes = """
    select id,
             duration_type,
             archived
      from flow.duration_type
      where archived is false
      """;

  //language=PostgreSQL
  public final static String getType = """
    select wqt.id,
               wqt.company_id,
               wqt.work_queue_type,
               wqt.archived,
               wqt.use_event_data,
               wqt.work_queue_category_id,
               wqc.work_queue_category,
               wqt.display_order,
               s.id as smartlist_id,
               wqc.color as work_queue_category_color,
               wqc.display_order as work_queue_category_display_order,
               wqt.short_window,
               wqt.hidden,
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
                                           WHERE wlp.white_list_type_id = 10
                                             AND wlp.archived is not true
                                             AND wlp.work_queue_type_id = :id) wlp), '[]') AS "hiddenWhiteListedPositions",
               wqt.short_window_duration_type_id,
               (select duration_type from flow.duration_type dt where dt.id = wqt.short_window_duration_type_id) as short_window_duration_type,
               wqt.long_window,
               wqt.long_window_duration_type_id,
               (select duration_type from flow.duration_type dt where dt.id = wqt.short_window_duration_type_id) as long_window_duration_type,
               wqt.expected_cycle,
               wqt.expected_cycle_duration_type_id,
               (select duration_type from flow.duration_type dt where dt.id = wqt.short_window_duration_type_id) as expected_cycle_duration_type,
               expected_target,
               inverse_expectation,
               json(wqt.schedule) as schedule
        from flow.work_queue_type wqt
               inner join flow.work_queue_category wqc on wqc.id = wqt.work_queue_category_id
               inner join flow.smartlist s on s.work_queue_type_id = wqt.id
        where wqt.id = :id
        """;

  //language=PostgreSQL
  public final static String addSmartlist = """
    insert into flow.smartlist (name, company_object_type_id, shared, owner_id, view_object_type_id, main_process_steps, project_details, work_queue_type_id, created_by_id, date_created, modified_by_id, date_modified)
        values (:workQueueType,
                (select id from flow.company_object_type cot where cot.company_id = :companyId and cot.object_type_id = :objectTypeId),
                true, 99999999,  1, true, false, :workQueueTypeId, :createdById, now(), :createdById, now())
        """;

  //language=PostgreSQL
  public final static String deleteType = """
    update flow.work_queue_type
    set archived = true,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String saveHidden = """
    update flow.work_queue_type
       set hidden = :hidden,
           modified_by_id = :userId,
           date_modified = now()
       where id = :wqtId
     """;

  //language=PostgreSQL
  public final static String archiveWhiteListPositions = """
    update flow.white_listed_position
         set archived = true,
             date_modified = now(),
             modified_by_id = :userId
       where work_queue_type_id = :wqtId
         and company_id = :companyId
         and white_list_type_id = :whiteListTypeId
       """;

  //language=PostgreSQL
  public final static String insertWhiteListPosition = """
    insert into flow.white_listed_position(position_id, work_queue_type_id, white_list_type_id, company_id, created_by_id, date_created, modified_by_id, date_modified)
       select :positionId, :wqtId, :whiteListTypeId, :companyId, :userId, now(), :userId, now()
       where not exists (  select id
                           from flow.white_listed_position
                           where work_queue_type_id = :wqtId
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
       where work_queue_type_id = :wqtId
         and position_id not in (:positionIdsUsed)
         and company_id = :companyId
         and white_list_type_id = :whiteListTypeId
       """;

  //language=PostgreSQL
  public final static String getProcessStepsUsingWqt = """
    select ps.process_step_name
       from flow.process_step_work_queue_type pswqt
         inner join flow.process_step ps on pswqt.process_step_id = ps.id
       where pswqt.work_queue_type_id = :wqtId
       and pswqt.archived is false
       and ps.archived is false
       union
       select concat(ps.process_step_name, ' - ', e.event_name, ' (event)') as process_step_name
       from flow.process_step_event_work_queue_type pswqt
              inner join flow.process_step_event pse on pswqt.process_step_event_id = pse.id
              inner join flow.event e on pse.event_id = e.id
              inner join flow.process_step ps on pse.process_step_id = ps.id
       where pswqt.work_queue_type_id = :wqtId
         and pswqt.archived is false
         and pse.archived is false
         and ps.archived is false
       order by process_step_name
       """;

  //language=PostgreSQL
  public final static String updateType = """
    update flow.work_queue_type
         set work_queue_type = :workQueueType,
             modified_by_id = :modifiedById,
             date_modified = now(),
             use_event_data = :useEventData,
             work_queue_category_id = :workQueueCategoryId,
             display_order = :displayOrder,
             short_window = :shortWindow,
             short_window_duration_type_id = :shortWindowDurationTypeId,
             long_window = :longWindow,
             long_window_duration_type_id = :longWindowDurationTypeId,
             expected_cycle = :expectedCycle,
             expected_cycle_duration_type_id = :expectedCycleDurationTypeId,
             inverse_expectation = :inverseExpectation,
             expected_target = :expectedTarget,
             schedule = :schedule
         where id = :id
       """;

  //language=PostgreSQL
  public final static String insertType = """
    insert into flow.work_queue_type(company_id, work_queue_type, work_queue_category_id, display_order, created_by_id, date_created, modified_by_id, date_modified, use_event_data)
      values (:companyId, :workQueueType, :workQueueCategoryId, (select coalesce(max(display_order) + 1, 0) from flow.work_queue_type where work_queue_category_id = :workQueueCategoryId and archived is not true), :createdById, now(),  :createdById, now(), :useEventData)
        """;

  //language=PostgreSQL
  public final static String getAvailableWorkQueueTypesForStep = """
    select wqt.id,
               wqt.company_id,
               work_queue_type,
               work_queue_category_id,
               wqt.date_created,
               wqt.date_modified,
               wqt.created_by_id,
               wqt.modified_by_id,
               wqt.archived,
               wqt.display_order,
               long_window,
               short_window,
               long_window_duration_type_id,
               short_window_duration_type_id,
               expected_cycle,
               expected_cycle_duration_type_id,
               expected_target,
               inverse_expectation,
               wqc.work_queue_category
        from flow.work_queue_type wqt
            inner join flow.work_queue_category wqc on wqc.id = wqt.work_queue_category_id
        where wqt.archived is not true
          and wqt.company_id = :companyId
          and wqt.use_event_data is false
          and not exists (
                select process_step_id
                from flow.process_step_work_queue_type pswqt
                where pswqt.work_queue_type_id = wqt.id
                  and pswqt.process_step_id = :id
                  and archived is not true
            )
        order by wqt.work_queue_type
        """;

  //language=PostgreSQL
  public final static String getProcessStepWorkQueueType = """
    SELECT pswqt.id,
          pswqt.work_queue_type_id,
          pswqt.created_by_id,
          pswqt.process_step_id,
          pswqt.modified_by_id,
          wqt.work_queue_type,
          wqc.work_queue_category,
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
       where pswqt.id = :id
       """;

  //language=PostgreSQL
  public final static String insertProcessStepWorkQueueType = """
    insert into flow.process_step_work_queue_type (process_step_id, work_queue_type_id, created_by_id, modified_by_id, date_created, date_modified)
        values (:processStepId, :workQueueTypeId, :createdById, :createdById, now(), now())
        on conflict (process_step_id,work_queue_type_id)
          do update set archived = false, date_modified = now(), modified_by_id = excluded.modified_by_id
      """;

  //language=PostgreSQL
  public final static String deleteProcessStepWorkQueueType = """
    update flow.process_step_work_queue_type
         set archived = true,
           modified_by_id = :modifiedById,
           date_modified = now()
         where id = :id;
         update flow.process_step_work_queue_type_project_status_type
         set archived = true,
             modified_by_id = :modifiedById,
             date_modified = now()
         where process_step_work_queue_type_id = :id;
         update flow.process_step_work_queue_type_process_step_status_type
         set archived = true,
             modified_by_id = :modifiedById,
             date_modified = now()
         where process_step_work_queue_type_id = :id
       """;

  //language=PostgreSQL
  public final static String callPsConfigChangeFunction = """
    select * from flow.ps_wqt_configuration_change(:psWqtId::bigint, :createdById::bigint)
        """;

  //language=PostgreSQL
  public final static String insertProjectStatusTypeForProcessStep = """
    insert into flow.process_step_work_queue_type_project_status_type(company_project_status_type_id, project_status_type_id, process_step_work_queue_type_id, created_by_id, date_created, modified_by_id, date_modified)
        values (:companyProjectStatusTypeId, :projectStatusTypeId, :processStepWorkQueueTypeId, :userId, now(), :userId, now())
        on conflict (coalesce(company_project_status_type_id, -1), coalesce(project_status_type_id, -1), process_step_work_queue_type_id)
            do update set archived = false, modified_by_id = excluded.modified_by_id, date_modified = now()
        """;

  //language=PostgreSQL
  public final static String updateProjectStatusTypeForProcessStep = """
    update flow.process_step_work_queue_type_project_status_type
      set archived = true,
          modified_by_id = :userId,
          date_modified = now()
      where id = :id
      """;

  //language=PostgreSQL
  public final static String getProjectStatusesForPsWorkQueueType = """
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
         WHERE pswqtpst.process_step_work_queue_type_id = :processStepWorkQueueTypeId
           AND pswqtpst.archived is not true
         order by pst.project_status_type, cpst.project_status_type
       """;

  //language=PostgreSQL
  public final static String insertProcessStepStatusTypeForProcessStep = """
    insert into flow.process_step_work_queue_type_process_step_status_type(company_process_step_status_type_id, process_step_status_type_id, process_step_work_queue_type_id, created_by_id, modified_by_id, date_created, date_modified)
       values (:companyProcessStepStatusTypeId, :processStepStatusTypeId, :processStepWorkQueueTypeId, :userId, :userId, now(), now())
       on conflict (coalesce(company_process_step_status_type_id, -1), coalesce(process_step_status_type_id, -1), process_step_work_queue_type_id)
       do update set archived = false, date_modified = now(), modified_by_id = excluded.modified_by_id
       """;

  //language=PostgreSQL
  public final static String updateProcessStepStatusTypeForProcessStep = """
    update flow.process_step_work_queue_type_process_step_status_type
       set archived = true,
           modified_by_id = :userId,
           date_modified = now()
       where id = :id
       """;

  //language=PostgreSQL
  public final static String getProcessStepStatusesForPsWorkQueueType = """
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
       WHERE pswqtpsst.process_step_work_queue_type_id = :processStepWorkQueueTypeId
         AND pswqtpsst.archived is not true
       order by psst.process_step_status_type, cpsst.process_step_status_type
       """;

  //language=PostgreSQL
  public final static String getAvailableWorkQueueTypesForEvent = """
    select wqt.id,
              wqt.company_id,
              work_queue_type,
              work_queue_category_id,
              wqt.date_created,
              wqt.date_modified,
              wqt.created_by_id,
              wqt.modified_by_id,
              wqt.archived,
              wqt.display_order,
              long_window,
              short_window,
              long_window_duration_type_id,
              short_window_duration_type_id,
              expected_cycle,
              expected_cycle_duration_type_id,
              expected_target,
              inverse_expectation,
              wqc.work_queue_category
       from flow.work_queue_type wqt
           inner join flow.work_queue_category wqc on wqc.id = wqt.work_queue_category_id
       where wqt.archived is not true
         and wqt.company_id = :companyId
         and wqt.use_event_data is true
         and not exists (
               select process_step_event_id
               from flow.process_step_event_work_queue_type pswqt
               where pswqt.work_queue_type_id = wqt.id
                 and pswqt.process_step_event_id = :id
                 and archived is not true
           )
       order by wqt.work_queue_type
       """;

  //language=PostgreSQL
  public final static String deleteEventWorkQueueType = """
    update flow.process_step_event_work_queue_type
            set archived = true,
              modified_by_id = :modifiedById,
              date_modified = now()
            where id = :id;
            update flow.process_step_event_work_queue_type_project_status_type
              set archived = true,
                  modified_by_id = :modifiedById,
                  date_modified = now()
              where process_step_event_work_queue_type_id = :id;
              update flow.process_step_event_work_queue_type_process_step_status_type
              set archived = true,
                  modified_by_id = :modifiedById,
                  date_modified = now()
              where process_step_event_work_queue_type_id = :id
        """;

  //language=PostgreSQL
  public final static String insertProcessStepEventWorkQueueType = """
    insert into flow.process_step_event_work_queue_type (process_step_event_id, work_queue_type_id, created_by_id, modified_by_id, date_created, date_modified)
       values (:processStepEventId, :workQueueTypeId, :createdById, :createdById, now(), now())
       on conflict (process_step_event_id,work_queue_type_id)
         do update set archived = false, date_modified = now(), modified_by_id = excluded.modified_by_id
     """;

  //language=PostgreSQL
  public final static String insertProjectStatusTypeForEvent = """
    insert into flow.process_step_event_work_queue_type_project_status_type(company_project_status_type_id, project_status_type_id, process_step_event_work_queue_type_id, created_by_id, date_created, modified_by_id, date_modified)
          values (:companyProjectStatusTypeId, :projectStatusTypeId, :processStepEventWorkQueueTypeId, :userId, now(), :userId, now())
          on conflict (coalesce(company_project_status_type_id, -1), coalesce(project_status_type_id, -1), process_step_event_work_queue_type_id)
            do update set archived = false, modified_by_id = excluded.modified_by_id, date_modified = now()
        """;

  //language=PostgreSQL
  public final static String updateProjectStatusTypeForEvent = """
    update flow.process_step_event_work_queue_type_project_status_type
         set archived = true,
             modified_by_id = :userId,
             date_modified = now()
         where id = :id
       """;

  //language=PostgreSQL
  public final static String insertProcessStepStatusTypeForEvent = """
    insert into flow.process_step_event_work_queue_type_process_step_status_type(company_process_step_status_type_id, process_step_status_type_id, process_step_event_work_queue_type_id, created_by_id, modified_by_id, date_created, date_modified)
        values (:companyProcessStepStatusTypeId, :processStepStatusTypeId, :processStepEventWorkQueueTypeId, :userId, :userId, now(), now())
        on conflict (coalesce(company_process_step_status_type_id, -1), coalesce(process_step_status_type_id, -1), process_step_event_work_queue_type_id)
          do update set archived = false, date_modified = now(), modified_by_id = excluded.modified_by_id
        """;

  //language=PostgreSQL
  public final static String updateProcessStepStatusTypeForEvent = """
    update flow.process_step_event_work_queue_type_process_step_status_type
        set archived = true,
            modified_by_id = :userId,
            date_modified = now()
        where id = :id
        """;

  //language=PostgreSQL
  public final static String getProcessStepEventWorkQueueType = """
    SELECT pswqt.id,
              pswqt.work_queue_type_id,
              pswqt.created_by_id,
              pswqt.process_step_event_id,
              pswqt.modified_by_id,
              wqt.work_queue_type,
              wqc.work_queue_category,
              pswqt.archived,
              coalesce((
                         SELECT array_to_json(array_agg(row_to_json(projectStatuses)))
                         FROM (
                                SELECT pswqtpst.id,
                                       pswqtpst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
                                       pswqtpst.company_project_status_type_id as "companyProjectStatusTypeId",
                                       coalesce(pswqtpst.project_status_type_id, cpst.project_status_type_id) as "projectStatusTypeId",
                                       case when pswqtpst.project_status_type_id is not null then true else false end as "isRoot",
                                       case when pswqtpst.project_status_type_id is not null then 'Category' else 'Project Status' end as "group",
                                       case when pswqtpst.project_status_type_id is not null then concat(coalesce(cpst.project_status_type, pst.project_status_type), 'PST') else concat(coalesce(cpst.project_status_type, pst.project_status_type), 'CPST') end as "uniqueText",
                                       pswqtpst.archived,
                                       coalesce(cpst.project_status_type, pst.project_status_type) as "projectStatusType"
                                FROM flow.process_step_event_work_queue_type_project_status_type pswqtpst
                                       left join flow.company_project_status_type cpst on pswqtpst.company_project_status_type_id = cpst.id
                                       left join flow.project_status_type pst on pswqtpst.project_status_type_id = pst.id
                                WHERE pswqtpst.process_step_event_work_queue_type_id = pswqt.id AND pswqtpst.archived is not true
                                order by pst.project_status_type, cpst.project_status_type
                              ) projectStatuses), '[]') AS "projectStatuses",
              coalesce((
                         SELECT array_to_json(array_agg(row_to_json(processStepStatuses)))
                         FROM (
                                SELECT pswqtpsst.id,
                                       pswqtpsst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
                                       pswqtpsst.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
                                       coalesce(pswqtpsst.process_step_status_type_id, cpsst.process_step_status_type_id) as "processStepStatusTypeId",
                                       pswqtpsst.archived,
                                       case when pswqtpsst.process_step_status_type_id is not null then true else false end as "isRoot",
                                       case when pswqtpsst.process_step_status_type_id is not null then 'Category' else 'Process Step Status' end as "group",
                                       case when pswqtpsst.process_step_status_type_id is not null then concat(coalesce(cpsst.process_step_status_type, psst.process_step_status_type), 'PSST') else concat(coalesce(cpsst.process_step_status_type, psst.process_step_status_type), 'CPSST') end as "uniqueText",
                                       coalesce(cpsst.process_step_status_type, psst.process_step_status_type) as "processStepStatusType"
                                FROM flow.process_step_event_work_queue_type_process_step_status_type pswqtpsst
                                       left join flow.company_process_step_status_type cpsst on pswqtpsst.company_process_step_status_type_id = cpsst.id
                                       left join flow.process_step_status_type psst on pswqtpsst.process_step_status_type_id = psst.id
                                WHERE pswqtpsst.process_step_event_work_queue_type_id = pswqt.id AND pswqtpsst.archived is not true
                                order by psst.process_step_status_type, cpsst.process_step_status_type
                              ) processStepStatuses), '[]') AS "processStepStatuses",
              coalesce((
                         SELECT array_to_json(array_agg(row_to_json(eventStatuses)))
                         FROM (
                                SELECT pswqtpst.id,
                                       pswqtpst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
                                       pswqtpst.company_event_status_type_id as "companyEventStatusTypeId",
                                       coalesce(pswqtpst.event_status_type_id, cpst.event_status_type_id) as "eventStatusTypeId",
                                       case when pswqtpst.event_status_type_id is not null then true else false end as "isRoot",
                                       case when pswqtpst.event_status_type_id is not null then 'Category' else 'Event Status' end as "group",
                                       case when pswqtpst.event_status_type_id is not null then concat(coalesce(cpst.event_status_type, pst.event_status_type), 'EST') else concat(coalesce(cpst.event_status_type, pst.event_status_type), 'CEST') end as "uniqueText",
                                       pswqtpst.archived,
                                       coalesce(cpst.event_status_type, pst.event_status_type) as "eventStatusType"
                                FROM flow.process_step_event_work_queue_type_event_status_type pswqtpst
                                       left join flow.company_event_status_type cpst on pswqtpst.company_event_status_type_id = cpst.id
                                       left join flow.event_status_type pst on pswqtpst.event_status_type_id = pst.id
                                WHERE pswqtpst.process_step_event_work_queue_type_id = pswqt.id AND pswqtpst.archived is not true
                                order by pst.event_status_type, cpst.event_status_type
                              ) eventStatuses), '[]') AS "eventStatuses"
       FROM flow.process_step_event_work_queue_type pswqt
              inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id
              inner join flow.work_queue_category wqc on wqc.id = wqt.work_queue_category_id
       where pswqt.id = :id
       """;


  //language=PostgreSQL
  public final static String callEventConfigChangeFunction = """
    select * from flow.pse_wqt_configuration_change(:pseWqtId::bigint, :createdById::bigint)
       """;

  //language=PostgreSQL
  public final static String getProjectStatusesForEventWorkQueueType = """
    SELECT pswqtpst.id,
             pswqtpst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
             pswqtpst.company_project_status_type_id as "companyProjectStatusTypeId",
             coalesce(pswqtpst.project_status_type_id, cpst.project_status_type_id) as "projectStatusTypeId",
             case when pswqtpst.project_status_type_id is not null then true else false end as "isRoot",
             case when pswqtpst.project_status_type_id is not null then 'Category' else 'Project Status' end as "group",
             case when pswqtpst.project_status_type_id is not null then concat(coalesce(cpst.project_status_type, pst.project_status_type), 'PST') else concat(coalesce(cpst.project_status_type, pst.project_status_type), 'CPST') end as "uniqueText",
             pswqtpst.archived,
             coalesce(cpst.project_status_type, pst.project_status_type) as "projectStatusType"
      FROM flow.process_step_event_work_queue_type_project_status_type pswqtpst
             left join flow.company_project_status_type cpst on pswqtpst.company_project_status_type_id = cpst.id
             left join flow.project_status_type pst on pswqtpst.project_status_type_id = pst.id
      WHERE pswqtpst.process_step_event_work_queue_type_id = :processStepEventWorkQueueTypeId
        AND pswqtpst.archived is not true
      order by pst.project_status_type, cpst.project_status_type
      """;

  //language=PostgreSQL
  public final static String getProcessStepStatusesForEventWorkQueueType = """
    SELECT pswqtpsst.id,
             pswqtpsst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
             pswqtpsst.company_process_step_status_type_id as "companyProcessStepStatusTypeId",
             coalesce(pswqtpsst.process_step_status_type_id, cpsst.process_step_status_type_id) as "processStepStatusTypeId",
             pswqtpsst.archived,
             case when pswqtpsst.process_step_status_type_id is not null then true else false end as "isRoot",
             case when pswqtpsst.process_step_status_type_id is not null then 'Category' else 'Process Step Status' end as "group",
             case when pswqtpsst.process_step_status_type_id is not null then concat(coalesce(cpsst.process_step_status_type, psst.process_step_status_type), 'PSST') else concat(coalesce(cpsst.process_step_status_type, psst.process_step_status_type), 'CPSST') end as "uniqueText",
             coalesce(cpsst.process_step_status_type, psst.process_step_status_type) as "processStepStatusType"
      FROM flow.process_step_event_work_queue_type_process_step_status_type pswqtpsst
             left join flow.company_process_step_status_type cpsst on pswqtpsst.company_process_step_status_type_id = cpsst.id
             left join flow.process_step_status_type psst on pswqtpsst.process_step_status_type_id = psst.id
      WHERE pswqtpsst.process_step_event_work_queue_type_id = :processStepEventWorkQueueTypeId
        AND pswqtpsst.archived is not true
      order by psst.process_step_status_type, cpsst.process_step_status_type
      """;

  //language=PostgreSQL
  public final static String getEventStatusesForWorkQueueType = """
    SELECT pswqtpst.id,
              pswqtpst.process_step_event_work_queue_type_id as "processStepEventWorkQueueTypeId",
              pswqtpst.company_event_status_type_id as "companyEventStatusTypeId",
              coalesce(pswqtpst.event_status_type_id, cpst.event_status_type_id) as "eventStatusTypeId",
              case when pswqtpst.event_status_type_id is not null then true else false end as "isRoot",
              case when pswqtpst.event_status_type_id is not null then 'Category' else 'Event Status' end as "group",
              case when pswqtpst.event_status_type_id is not null then concat(coalesce(cpst.event_status_type, pst.event_status_type), 'EST') else concat(coalesce(cpst.event_status_type, pst.event_status_type), 'CEST') end as "uniqueText",
              pswqtpst.archived,
              coalesce(cpst.event_status_type, pst.event_status_type) as "eventStatusType"
       FROM flow.process_step_event_work_queue_type_event_status_type pswqtpst
              left join flow.company_event_status_type cpst on pswqtpst.company_event_status_type_id = cpst.id
              left join flow.event_status_type pst on pswqtpst.event_status_type_id = pst.id
       WHERE pswqtpst.process_step_event_work_queue_type_id = :processStepEventWorkQueueTypeId
         AND pswqtpst.archived is not true
       order by pst.event_status_type, cpst.event_status_type
       """;


  //language=PostgreSQL
  public final static String insertEventStatusType = """
    insert into flow.process_step_event_work_queue_type_event_status_type(company_event_status_type_id, event_status_type_id, process_step_event_work_queue_type_id, created_by_id, modified_by_id, date_created, date_modified)
    values (:companyEventStatusTypeId, :eventStatusTypeId, :processStepEventWorkQueueTypeId, :userId, :userId, now(), now())
    on conflict (coalesce(company_event_status_type_id, -1), coalesce(event_status_type_id, -1), process_step_event_work_queue_type_id)
      do update set archived = false, date_modified = now(), modified_by_id = excluded.modified_by_id
    """;

  //language=PostgreSQL
  public final static String updateEventStatusType = """
    update flow.process_step_event_work_queue_type_event_status_type
    set archived = true,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
    """;

}
