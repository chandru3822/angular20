package com.albatross.api.v1.company.blueraven.services.expenses.queries;

public class GlCodeQuery {

  //language=PostgreSQL
  public final static String getAllGlCodes = """
    SELECT
      id,
      code,
      description,
      archived
    FROM brs.gl_code gl
    where archived is false
    order by code
    """;

  //language=PostgreSQL
  public final static String getOneGlCode = """
    SELECT
      id,
      code,
      description,
      archived
    FROM brs.gl_code gl
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertGlCode = """
    INSERT INTO brs.gl_code(code, description, created_by_id, date_created, modified_by_id, date_modified)
    values(:code, :description, :userId, now(), :userId, now())
    """;

  //language=PostgreSQL
  public final static String updateGlCode = """
    UPDATE brs.gl_code
      SET code = :code,
          description = :description,
          modified_by_id = :userId,
          date_modified = now()
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String deleteGlCode = """
    UPDATE brs.gl_code
      SET archived = true,
          modified_by_id = :userId,
          date_modified = now()
    WHERE id = :id
    """;

}
