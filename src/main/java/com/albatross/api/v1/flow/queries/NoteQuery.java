package com.albatross.api.v1.flow.queries;

public class NoteQuery {

  //language=PostgreSQL
  public final static String getProjectProcessStepWorkQueueNotes = """
      select pn.id,
                                        pn.note,
                                        pn.archived,
                                        pn.parent_id,
                                        pn.date_created,
                                        pn.date_modified,
                                        pn.created_by_id,
                                        pn.follow_up_date as "followUpDate",
                                        concat(creator.first_name, ' ', creator.last_name) as created_by,
                                        pn.modified_by_id,
                                        pn.project_process_step_id,
                                        pn.process_step_work_queue_type_id,
                                        coalesce((
                                                     SELECT array_to_json(array_agg(row_to_json(childNotes)))
                                                     FROM (
                                                              select pn2.id,
                                                                     pn2.note,
                                                                     pn2.archived,
                                                                     pn2.date_created as "dateCreated",
                                                                     pn2.date_modified as "dateModified",
                                                                     pn2.created_by_id as "createdById",
                                                                     pn2.follow_up_date as "followUpDate",
                                                                     concat(creator2.first_name, ' ', creator2.last_name) as "createdBy",
                                                                     pn2.modified_by_id as "modifiedById",
                                                                     pn2.project_process_step_id as "projectProcessStepId",
                                                                     pn2.process_step_work_queue_type_id as "processStepWorkQueueTypeId"
                                                              from flow.project_process_step_process_step_work_queue_type_note pn2
                                                                       inner join flow.user creator2 on creator2.id = pn2.created_by_id
                                                              where pn2.archived is not true
                                                                and pn2.parent_id = pn.id
                                                              order by pn2.date_created
                                                          ) childNotes), '[]') AS "child_notes"
                                 from flow.project_process_step_process_step_work_queue_type_note pn
                                   inner join flow.user creator on creator.id = pn.created_by_id
                                 where pn.archived is not true
                                   and pn.parent_id is null
                                   and pn.project_process_step_id = :projectProcessStepId
                                   and pn.process_step_work_queue_type_id = :processStepWorkQueueTypeId
                                 order by pn.date_created desc;
    """;

  public final static String getNote = """
    select n.id,
           n.note,
           n.parent_id,
           n.date_created,
           n.date_modified,
           n.created_by_id,
           n.follow_up_date,
           n.archived,
           concat(creator.first_name, ' ', creator.last_name) AS created_by,
           n.modified_by_id
    from flow.%TABLE_NAME% n
    inner join flow.user creator on creator.id = n.created_by_id
    where n.id = :id
    """;

  public final static String updateNote = """
    update flow.%TABLE_NAME%
        set note = :note,
            modified_by_id = :userId,
            date_modified = now(),
            follow_up_date = :followUpDate::date
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertProjectProcessStepWorkQueueNote = """
    insert into flow.project_process_step_process_step_work_queue_type_note(project_process_step_id, process_step_work_queue_type_id, parent_id, note, follow_up_date, created_by_id, date_created, modified_by_id, date_modified)
      values (:projectProcessStepId, :processStepWorkQueueTypeId, :parentId, :note, :followUpDate::date, :userId, now(), :userId, now())
    """;

  //language=PostgreSQL
  public final static String insertProjectProcessStepEventWorkQueueNote = """
    insert into flow.pps_event_process_step_event_work_queue_type_note(project_process_step_event_id, process_step_event_work_queue_type_id, parent_id, note, follow_up_date, created_by_id, date_created, modified_by_id, date_modified)
      values (:projectProcessStepEventId, :processStepEventWorkQueueTypeId, :parentId, :note, :followUpDate::date, :userId, now(), :userId, now())
    """;

  //language=PostgreSQL
  public final static String insertProjectProdStatsNote = """
insert into flow.project_prod_stats_note(project_id, project_production_stats_type_id, parent_id, note, follow_up_date, created_by_id, date_created, modified_by_id, date_modified)
      values (:projectId, (select id from flow.project_production_stats_type where production_stats_type = :productionType), :parentId, :note, :followUpDate::date, :userId, now(), :userId, now())
    """;

  public final static String deleteNote = """
    update flow.%TABLE_NAME%
        set archived = true,
            modified_by_id = :modifiedById,
            date_modified = now()
    where id = :noteId
    """;

  public final static String insertNoteTimer = """
    insert into flow.interaction_timer(user_id, project_id, start_timestamp, end_timestamp, timer_type, start_event, end_event)
    values (:userId, :projectId, :startTimestamp, :endTimestamp, :timerType, :startEvent, :endEvent)
    """;

}
