package com.albatross.api.v1.flow.queries;

public class MessageTemplateQuery {

  //language=PostgreSQL
  public final static String getAllTemplates = """
    select id, title, message, to_jsonb(team_ids) as teamIds, archived
      from flow.message_template mt
      where mt.archived is not true
    """;

  //language=PostgreSQL
  public final static String getAllTemplatesWithTeamInfo = """
      select id, title, message, archived,
             coalesce((
                        SELECT array_to_json(array_agg(row_to_json(team)))
                        FROM (
                          select st.id,
                                 st.team_name as "teamName"
                          from flow.sms_team st
                          where st.id = any(mt.team_ids)
                          and st.archived is false
                               ) team), '[]') AS "teams"
      from flow.message_template mt
      where mt.archived is not true
      order by title
    """;

  //language=PostgreSQL
  public final static String getTemplates = """
    select id, title, message, to_jsonb(team_ids) as teamIds, archived
      from flow.message_template mt
      where mt.archived is not true
      and :teamId::bigint = any(mt.team_ids)
    """;

  //language=PostgreSQL
  public final static String getTemplate = """
    select id, title, message, to_jsonb(team_ids) as teamIds, archived
      from flow.message_template mt
      where mt.archived is not true
      and id = :id
    """;

  //language=PostgreSQL
  public final static String insertTemplate = """
      insert into flow.message_template
      (title, message, team_ids, created_by_id, date_created, modified_by_id, date_modified)
      values (:title, :message, array[ :teamIds ]::bigint[], :createdById, now(), :createdById, now())
    """;

  //language=PostgreSQL
  public final static String updateTemplate = """
    update flow.message_template set
        title = :title,
        message = :message,
        team_ids = array[ :teamIds ]::bigint[],
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteTemplate = """
    update flow.message_template set
        archived = true,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

}
