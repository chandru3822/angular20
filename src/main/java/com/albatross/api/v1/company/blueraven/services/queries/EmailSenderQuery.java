package com.albatross.api.v1.company.blueraven.services.queries;

public class EmailSenderQuery {

  //language=PostgreSQL
  public final static String getEmailSenders = """
    SELECT
           ems.id,
           ems.email_address,
           ems.date_modified,
           ems.modified_by_id as "modifiedById",
           ems.date_created,
           ems.created_by_id as "createdById",
           ems.archived
    FROM brs.email_sender ems
    WHERE archived is not true
    ORDER BY ems.email_address
    """;

  //language=PostgreSQL
  public final static String updateEmailSender = """
    update brs.email_sender
      set email_address = :emailAddress,
          date_modified = now(),
          modified_by_id = :modifiedById,
          archived = :archived
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertEmailSender = """
    insert into brs.email_sender(email_address, archived, date_created, created_by_id, date_modified, modified_by_id )
    values (:emailAddress, false, now(), :createdById, now(), :createdById)
    returning *
    """;

  //language=PostgreSQL
  public final static String deleteEmailSender = """
    update brs.email_sender set archived = true, date_modified = now() where id = :id
    """;
}
