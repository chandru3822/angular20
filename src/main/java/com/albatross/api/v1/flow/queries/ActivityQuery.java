package com.albatross.api.v1.flow.queries;

public class ActivityQuery {

  //language=PostgreSQL
  public final static String getProjectActivities = """
      select pa.id,
             pa.project_id,
             pa.date_modified,
             pa.note,
             pa.date_created,
             pa.created_by_id,
             concat(u.first_name, ' ', u.last_name) as "createdBy",
             concat(p.position, ' (', o.org_name, ')') as "createdByPosition",
             pa.modified_by_id,
             pa.archived,
             pa.activity_type_id
      from flow.project_activity pa
        inner join flow."user" u on u.id = pa.created_by_id
        inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true and up.archived is false
        inner join flow.position p on p.id = up.position_id
        inner join flow.org o on o.id = up.org_id
      where pa.archived is false
       and pa.project_id = :sourceId
    """;

  //language=PostgreSQL
  public final static String getProjectActivity = """
      select pa.id,
             pa.project_id,
             pa.date_modified,
             pa.note,
             pa.date_created,
             pa.created_by_id,
             concat(u.first_name, ' ', u.last_name) as "createdBy",
             concat(p.position, ' (', o.org_name, ')') as "createdByPosition",
             pa.modified_by_id,
             pa.archived,
             pa.activity_type_id
      from flow.project_activity pa
        inner join flow."user" u on u.id = pa.created_by_id
        inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true and up.archived is false
        inner join flow.position p on p.id = up.position_id
        inner join flow.org o on o.id = up.org_id
      where pa.archived is false
       and pa.id = :id
    """;

  //language=PostgreSQL
  public final static String addProjectActivity = """
      insert into flow.project_activity(project_id, date_modified, note, date_created, created_by_id, modified_by_id, archived, activity_type_id)
      values (:sourceId, now(), :note, now(), :userId, :userId, false, :activityTypeId);
    """;

}
