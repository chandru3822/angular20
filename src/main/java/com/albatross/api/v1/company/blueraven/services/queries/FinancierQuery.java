package com.albatross.api.v1.company.blueraven.services.queries;

public class FinancierQuery {

  //language=PostgreSQL
  public final static String getActive = """
    SELECT id,
           name,
           submission_method,
           archived,
           date_created,
           created_by_id,
           date_modified,
           modified_by_id
    FROM brs.financier
    WHERE archived IS NOT TRUE
    ORDER BY name
    """;

  //language=PostgreSQL
  public final static String add = """
    INSERT INTO brs.financier (name, submission_method, archived, date_created, created_by_id, date_modified, modified_by_id)
    VALUES (:name, :submissionMethod, FALSE, now(), :currentUser, now(), :currentUser)
    RETURNING id;
    """;

  //language=PostgreSQL
  public final static String update = """
    UPDATE brs.financier
    SET name = :name,
        submission_method = :submissionMethod,
        archived = :archived,
        date_modified = now(),
        modified_by_id = :currentUser
    WHERE id = :id
    """;
}
