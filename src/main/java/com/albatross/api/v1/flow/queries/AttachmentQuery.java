package com.albatross.api.v1.flow.queries;

public class AttachmentQuery {

  //language=PostgreSQL
  public final static String findById = """
 SELECT a.id,
           a.attachment_type_id,
           a.company_id,
           a.filename,
           a.content_type,
           a.s3_key,
           a.display_name,
           a.size,
           a.uuid,
           a.archived,
           substring(filename, '\\.([^\\.]+)$') as file_extension,
           a.date_created,
           a.date_modified,
           a.created_by_id,
           a.modified_by_id,
           a.show,
           concat(u.first_name, ' ', u.last_name) as uploaded_by,
           att.attachment_type,
           orgn.*
    FROM flow.attachment a
      inner join flow."user" u on u.id = a.created_by_id
      inner join flow.attachment_type att on a.attachment_type_id = att.id
      left join lateral ( select * from flow.get_attachment_origin(a.id)) orgn on true
    WHERE a.id = :id
      and a.archived is not true
    """;

  //language=PostgreSQL
  public final static String getAttachmentForUuidCheck = """
 SELECT
      a.id,
      a.content_type,
      a.display_name,
      a.filename,
      a.s3_key,
      a.uuid
    FROM flow.attachment a
    WHERE a.id = :id
      AND a.archived IS NOT TRUE
    """;

  //language=PostgreSQL
  public final static String getAttachmentById = """
SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      a.filename,
      a.uuid,
      a.s3_key,
      a.display_name,
      a.size,
      substring(a.filename, '\\.([^\\.]+)$') as file_extension,
      a.archived,
      a.date_created,
      concat(u.first_name, ' ', u.last_name) as uploaded_by,
      a.date_modified
    FROM flow.attachment a
    inner join flow."user" u on u.id = a.created_by_id
    WHERE a.id = :id
      AND a.archived IS NOT TRUE
    """;

  //language=PostgreSQL
  public final static String getAttachmentsByType = """
SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      a.filename,
      a.s3_key,
      a.size,
      a.display_name,
      a.uuid,
      a.show,
      substring(a.filename, '\\.([^\\.]+)$') as file_extension,
      src.source_id,
      a.date_created,
      concat(u.first_name, ' ', u.last_name) as uploaded_by,
      a.date_modified,
      a.archived
    FROM flow.attachment a
      INNER JOIN flow.attachment_source src ON src.attachment_id = a.id
      inner join flow."user" u on u.id = a.created_by_id
    WHERE a.attachment_type_id = :attachmentTypeId
      AND a.archived IS NOT TRUE
      order by a.date_created desc
    """;

  //language=PostgreSQL
  public final static String getAttachmentByUUID = """
    SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      a.filename,
      a.s3_key,
      a.display_name,
      a.size,
      a.uuid,
      a.show,
      substring(a.filename, '\\.([^\\.]+)$') as file_extension,
      a.date_created,
      concat(u.first_name, ' ', u.last_name) as uploaded_by,
      a.date_modified,
      a.archived
    FROM flow.attachment a
    inner join flow."user" u on u.id = a.created_by_id
    WHERE a.uuid = :uuid
    """;

  //language=PostgreSQL
  public final static String getAttachmentsByTypeNoSource = """
SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      a.filename,
      a.s3_key,
      a.size,
      a.display_name,
      a.uuid,
      a.show,
      substring(a.filename, '\\.([^\\.]+)$') as file_extension,
      a.date_created,
      concat(u.first_name, ' ', u.last_name) as uploaded_by,
      a.date_modified,
      a.archived
    FROM flow.attachment a
    inner join flow."user" u on u.id = a.created_by_id
    WHERE a.attachment_type_id = :attachmentTypeId
      AND a.archived IS NOT TRUE
      order by a.date_created desc
    """;

  //language=PostgreSQL
  public final static String getAttachmentBySourceAndType = """
    SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      substring(a.filename, '\\.([^\\.]+)$') as file_extension,
      a.filename,
      a.s3_key,
      a.size,
      a.uuid,
      a.display_name,
      a.archived,
      src.source_id,
      a.date_created,
      concat(u.first_name, ' ', u.last_name) as uploaded_by,
      a.date_modified
    FROM flow.attachment a
      INNER JOIN flow.attachment_source src ON src.attachment_id = a.id
      inner join flow."user" u on u.id = a.created_by_id
    WHERE src.source_id = :sourceId
      AND a.attachment_type_id = :attachmentTypeId
      AND a.archived IS NOT TRUE
    LIMIT 1
    """;

  //language=PostgreSQL
  public final static String getAttachmentsBySourceIdAndType = """
    SELECT a.id,
           a.attachment_type_id,
           a.content_type,
           a.filename,
           a.uuid,
           a.s3_key,
           a.display_name,
           a.size,
           concat(u.first_name, ' ', u.last_name) as uploaded_by,
           substring(a.filename, '\\.([^\\.]+)$') as file_extension,
           src.source_id,
           a.archived,
           false as linked
    FROM flow.attachment a
             LEFT JOIN flow.attachment_source src ON src.attachment_id = a.id
             inner join flow."user" u on u.id = a.created_by_id
    WHERE case when :sourceId::bigint IS NOT NULL then src.source_id = :sourceId else 1 = 1 end
      AND a.attachment_type_id = :attachmentTypeId
      AND a.archived IS NOT TRUE
    """;

  //language=PostgreSQL
  public final static String getAttachmentBySourceAndTypeForUserList = """
SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      a.filename,
      a.s3_key,
      a.size,
      a.uuid,
      a.display_name,
      a.archived,
      substring(a.filename, '\\.([^\\.]+)$') as file_extension,
      src.source_id,
      a.date_created,
      concat(u.first_name, ' ', u.last_name) as uploaded_by,
      a.date_modified
    FROM flow.attachment a
      INNER JOIN flow.attachment_source src ON src.attachment_id = a.id
      inner join flow."user" u on u.id = a.created_by_id
    WHERE src.source_id = any( array [ :sourceIds ]::bigint[] )
      AND a.attachment_type_id = :attachmentTypeId
      AND a.archived is not true
    """;

  //language=PostgreSQL
  public final static String create = """
INSERT INTO flow.attachment(filename, content_type, s3_key, size, date_created, created_by_id, date_modified, modified_by_id, attachment_type_id, company_id, uuid, display_name)
    VALUES(:filename, :contentType, :key, :size, now(), :createdById, now(), :createdById, :attachmentTypeId, :companyId, uuid_generate_v4(), :displayName)
    """;

  //language=PostgreSQL
  public final static String addToJoinTable = """
    INSERT INTO flow.attachment_source(attachment_id, source_id)
    VALUES (:attachmentId, :sourceId)
    """;

  //language=PostgreSQL
  public final static String deleteById = """
    UPDATE flow.attachment
    SET
      archived = TRUE,
      date_modified = now(),
      modified_by_id = :modifiedById
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String deleteBySourceAndType = """
    UPDATE flow.attachment a
    SET
      archived = TRUE,
      date_modified = now(),
      modified_by_id = :modifiedById
    FROM (
      SELECT src.attachment_id
      FROM flow.attachment_source src
        inner join flow.attachment a on a.id = src.attachment_id
      WHERE src.source_id = :sourceId
        AND a.attachment_type_id = :attachmentTypeId
    ) AS s
    WHERE a.id = s.attachment_id
    """;

  //language=PostgreSQL
  public final static String getAttachmentType = """
    select at.id,
           at.attachment_type,
           at.is_system,
           at.key_pattern_id,
           kp.key_pattern
    from flow.attachment_type at
      inner join flow.key_pattern kp on kp.id = at.key_pattern_id
    where at.id = :id
    """;

  //language=PostgreSQL
  public final static String getAttachmentSource = """
select project_id as id_to_use,
           'project' as object_type_text
    from flow.project_attachment
    where attachment_id = :attachmentId
    and linked is false
    and archived is false
    union
    select project_process_step_id as id_to_use,
           'process_step' as object_type_text
    from flow.project_process_step_attachment
    where attachment_id = :attachmentId
      and linked is false
      and archived is false
    union
    select project_process_step_event_id as id_to_use,
           'event' as object_type_text
    from flow.project_process_step_event_attachment
    where attachment_id = :attachmentId
      and linked is false
      and archived is false
    union
    select contact_id as id_to_use,
           'contact' as object_type_text
    from flow.contact_attachment
    where attachment_id = :attachmentId
      and linked is false
      and archived is false
    union
    select user_id as id_to_use,
           'user' as object_type_text
    from flow.user_attachment
    where attachment_id = :attachmentId
      and linked is false
      and archived is false
    union
    select org_id as id_to_use,
           'org' as object_type_text
    from flow.org_attachment
    where attachment_id = :attachmentId
      and linked is false
      and archived is false
    """;

  //language=PostgreSQL
  public final static String update = """
    update flow.attachment
    set display_name = :displayName,
        date_modified = now(),
        modified_by_id = :userId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getComparisonFields = """
    select *
    from flow.get_attachment_compare_fields(:attachmentId::bigint);
    """;

}
