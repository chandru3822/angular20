package com.albatross.api.v1.company.blueraven.services.queries;

public class MessageTypeQuery {

  //language=PostgreSQL
  public final static String getMessageTypes = """
    select id,
           title,
           content,
           description,
           include_manager,
           archived
    from brs.message_type mt
    where mt.archived is false
    order by mt.id
    """;

  //language=PostgreSQL
  public final static String getOneMessageType = """
    select id,
           title,
           content,
           description,
           include_manager,
           archived
    from brs.message_type mt
    where mt.archived is false
    and mt.id = :id
    """;

  //language=PostgreSQL
  public final static String insertMessageType = """
    insert into brs.message_type (title, content, description, include_manager, created_by_id, modified_by_id)
    values(:title, :content, :description, :includeManager, :userId, :userId)
    """;

  //language=PostgreSQL
  public final static String updateMessageType = """
    update brs.message_type
    set title = :title,
        description = :description,
        content = :content,
        include_manager = :includeManager,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteMessageType = """
    update brs.message_type
    set archived = true,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String updateDbParamDesc = """
    update flow.db_function_param dfp
        set description = ( select string_agg(concat(mt.id, ': ', mt.title), '
    ' order by id)
    from brs.message_type mt
    where mt.archived is false
    )
    where dfp.id = 33;
  """;


}
