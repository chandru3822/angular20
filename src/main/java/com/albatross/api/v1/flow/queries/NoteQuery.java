package com.albatross.api.v1.flow.queries;

public class NoteQuery {

  //language=PostgreSQL
  public final static String getByPrimaryAndType = """
select * from flow.get_notes(:primaryId::bigint, :typeId::bigint, :companyId::bigint)
    """;

  //language=PostgreSQL
  public final static String getProjectProcessStepWorkQueueNotes = """
select n.id,
       n.note,
       n.archived,
       n.parent_id,
       n.date_created,
       n.date_modified,
       n.created_by_id,
       n.follow_up_date as "followUpDate",
       concat(creator.first_name, ' ', creator.last_name) as created_by,
       n.modified_by_id,
       pn.project_process_step_id,
       pn.process_step_work_queue_type_id,
       coalesce((
                    SELECT array_to_json(array_agg(row_to_json(childNotes)))
                    FROM (
                             select n2.id,
                                    n2.note,
                                    n2.archived,
                                    n2.date_created as "dateCreated",
                                    n2.date_modified as "dateModified",
                                    n2.created_by_id as "createdById",
                                    n2.follow_up_date as "followUpDate",
                                    concat(creator2.first_name, ' ', creator2.last_name) as "createdBy",
                                    n2.modified_by_id as "modifiedById",
                                    pn2.project_process_step_id as "projectProcessStepId",
                                    pn2.process_step_work_queue_type_id as "processStepWorkQueueTypeId"
                             from flow.note n2
                                      inner join flow.project_process_step_process_step_work_queue_type_note pn2 on pn2.note_id = n2.id
                                      inner join flow.user creator2 on creator2.id = n2.created_by_id
                             where n2.archived is not true
                               and n2.parent_id = n.id
                             order by n2.date_created
                         ) childNotes), '[]') AS "child_notes"
    from flow.note n
             inner join flow.project_process_step_process_step_work_queue_type_note pn on pn.note_id = n.id
             inner join flow.user creator on creator.id = n.created_by_id
    where n.archived is not true
      and n.parent_id is null
      and pn.project_process_step_id = :projectProcessStepId
      and pn.process_step_work_queue_type_id = :processStepWorkQueueTypeId
    order by n.date_created desc;
    """;

  //language=PostgreSQL
  public final static String insertNote = """
    insert into flow.note(parent_id, note, follow_up_date, created_by_id, date_created, modified_by_id, date_modified)
    values (:parentId, :note, :followUpDate::date, :userId, now(), :userId, now())
    """;

  //language=PostgreSQL
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
    from flow.note n
    inner join flow.user creator on creator.id = n.created_by_id
    where n.id = :id
    """;

  //language=PostgreSQL
  public final static String updateNote = """
    update flow.note
        set note = :note,
            modified_by_id = :userId,
            date_modified = now(),
            follow_up_date = :followUpDate::date
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertNoteRelation = """
select * from flow.insert_note_relation(:primaryId::bigint, :noteId::bigint, :typeId::bigint)
    """;

  //language=PostgreSQL
  public final static String insertProjectProcessStepWorkQueueNoteRelation = """
    insert into flow.project_process_step_process_step_work_queue_type_note(project_process_step_id, process_step_work_queue_type_id, note_id)
      values (:projectProcessStepId, :processStepWorkQueueTypeId, :noteId)
    """;

  //language=PostgreSQL
  public final static String insertProjectProcessStepEventWorkQueueNoteRelation = """
    insert into flow.pps_event_process_step_event_work_queue_type_note(project_process_step_event_id, process_step_event_work_queue_type_id, note_id)
      values (:projectProcessStepEventId, :processStepEventWorkQueueTypeId, :noteId)
    """;

  //language=PostgreSQL
  public final static String insertProjectProdStatsNoteRelation = """
insert into flow.project_prod_stats_note(project_id, project_production_stats_type_id, note_id)
      values (:projectId, (select id from flow.project_production_stats_type where production_stats_type = :productionType), :noteId)
    """;

  //language=PostgreSQL
  public final static String deleteNote = """
    update flow.note
        set archived = true,
            modified_by_id = :modifiedById,
            date_modified = now()
    where id = :noteId
    """;

}
