package com.albatross.api.v1.flow.queries;

public class EmailQuery {

  //language=PostgreSQL
  public final static String insert = """
    INSERT INTO flow.email_queue (
        user_id, subject, message,
        attachments, from_email, to_email, processed, from_display_name
    ) VALUES (
        :userId,
        :subject,
        :message,
        :attachments,
        :from,
        :to,
        :processed,
        :fromDisplayName
    )
    """;

  //language=PostgreSQL
  public final static String getAllUnprocessed = """
    select id,
           to_email as "to",
           from_email as "from",
           from_email as "fromDisplayName",
           subject,
           message as content,
           processed,
           user_id as "sentByUserId"
    from flow.email_queue
    where processed is not true
    """;

  //language=PostgreSQL
  public final static String markProcessed = """
    update flow.email_queue
    set processed = true,
        date_processed = now(),
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getDefaultSenderByCompanyId = """
            select
       email_address
            from flow.email_sender
            where is_default = true
            and company_id = :companyId
    """;

  //language=PostgreSQL
  public final static String getSendersByCompanyId = """
    SELECT
                       ems.id,
                       ems.email_address,
                       ems.sender_name,
                       ems.company_id,
                       ems.date_modified,
                       ems.modified_by_id as "modifiedById",
                       ems.date_created,
                       ems.created_by_id as "createdById",
                       ems.archived,
                       ems.is_default as "isDefault"
                FROM flow.email_sender ems
                WHERE archived is not true
                AND company_id = :companyId
                ORDER BY ems.email_address
        """;

  //language=PostgreSQL
  public final static String saveFromAddress = """
    INSERT INTO flow.email_sender (email_address, sender_name, company_id, created_by_id, date_created)
    select :emailAddress, :senderName, :companyId, :createdById, now()
    where not exists(select id from flow.email_sender where email_address = :emailAddress)
        """;

  //language=PostgreSQL
  public final static String updateEmailAddress = """
    update flow.email_sender
    set sender_name = :senderName, email_address = :emailAddress, modified_by_id = :modifiedBy, date_modified = now()
    where id = :id
        """;

  //language=PostgreSQL
  public final static String changeDefaultAddress = """
    update flow.email_sender
        set is_default =
    case
    when id = :id then true
    when id != :id then false
    end
    where company_id = :companyId
        """;

  //language=PostgreSQL
  public final static String deleteEmailAddress = """
    update flow.email_sender set archived = true, modified_by_id = :modifiedBy, date_modified = now() where id = :id
        """;

}
