package com.albatross.api.v1.flow.queries;

public class AppQuery {

  //language=PostgreSQL
  public final static String getLatestAppByAppTypeIdAndType = """
    SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      a.filename,
      a.s3_key,
      a.size,
      a.archived,
      ap.minimum_required_build_number,
      a.app_type_id,
      a.date_created,
      a.date_modified,
      a.show,
      a.beta
    FROM flow.app_attachment a
      INNER JOIN flow.app_type ap ON ap.id = a.app_type_id
    WHERE a.app_type_id = :appTypeId
      AND a.attachment_type_id = :attachmentTypeId
      AND a.archived IS NOT TRUE
        and a.show is true
      AND a.beta is false
    order by a.date_created desc
    LIMIT 1
    """;

  //language=PostgreSQL
  public final static String getMinVersionForType = """
    select minimum_required_build_number
    from flow.app_type
    where id = :appTypeId
    """;

  //language=PostgreSQL
  public final static String getBuildNumbersForType = """
    select build_number
    from flow.app_attachment
    where app_type_id = :appTypeId
    order by build_number desc
    """;

  //language=PostgreSQL
  public final static String saveMinVersionForType = """
    update flow.app_type
     set minimum_required_build_number = :minBuildNumber
    where id = :appTypeId
    """;

  //language=PostgreSQL
  public final static String deleteById = """
    UPDATE flow.app_attachment
    SET
      archived = TRUE,
      date_modified = now(),
      modified_by_id = :modifiedById
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String getAttachmentsByAttachmentType = """
 SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      a.filename,
      a.s3_key,
      a.size,
      a.display_name,
      a.show,
      a.app_type_id,
      ap.app_type,
      ap.minimum_required_build_number,
      a.date_created,
      a.date_modified,
      a.archived,
      a.beta
    FROM flow.app_attachment a
      INNER JOIN flow.app_type ap ON ap.id = a.app_type_id
      INNER JOIN flow.attachment_type at ON at.id = a.attachment_type_id
    WHERE at.id = :attachmentTypeId
      AND a.archived IS NOT TRUE
      order by a.date_created desc
    """;

  //language=PostgreSQL
  public final static String getAttachmentsByAppAndAttachmentType = """
SELECT
      a.id,
      a.attachment_type_id,
      a.content_type,
      a.filename,
      a.s3_key,
      a.size,
      a.show,
      a.display_name,
      a.app_type_id,
      ap.app_type,
      ap.minimum_required_build_number,
      a.date_created,
      a.date_modified,
      a.archived,
      a.beta
    FROM flow.app_attachment a
      INNER JOIN flow.app_type ap ON ap.id = a.app_type_id
      INNER JOIN flow.attachment_type at ON at.id = a.attachment_type_id
    WHERE at.id = :attachmentTypeId
      and ap.id = :appTypeId
      AND a.archived IS NOT TRUE
      order by a.date_created desc
    """;

  //language=PostgreSQL
  public final static String showOrHideAttachment = """
        UPDATE flow.app_attachment
            SET show = :show,
                date_modified = now(),
                modified_by_id = :userId
        WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String toggleBetaForAttachment = """
        UPDATE flow.app_attachment
            SET beta = :beta,
                date_modified = now(),
                modified_by_id = :userId
        WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String insertAttachmentRecord = """
INSERT INTO flow.app_attachment (filename, content_type, s3_key, size, date_created, company_id, attachment_type_id, app_type_id, created_by_id, display_name, version_number, build_number)
        VALUES (:filename, :contentType, :key, :size, now(), :companyId, :attachmentTypeId, :appTypeId, :createdById, :displayName, :versionNumber, :buildNumber)
    """;

  //language=PostgreSQL
  public final static String findById = """
           SELECT aa.*,
                  ap.app_type
           FROM flow.app_attachment aa
               inner join flow.app_type ap on ap.id = aa.app_type_id
           WHERE aa.id = :id
    """;

  //language=PostgreSQL
  public final static String deleteBySourceAndType = """
           UPDATE flow.app_attachment a
           SET
             archived = TRUE,
             date_modified = now(),
             modified_by_id = :modifiedById
           WHERE a.app_type_id = :appTypeId
               AND a.attachment_type_id = :attachmentTypeId
    """;

  //language=PostgreSQL
  public final static String createMissingTable = """
       create table if not exists flow.app_attachment
           (
               id                 serial                  not null
                   constraint flow_app_attachment_pk
                       primary key,
               company_id         integer                 not null
                   constraint flow_aa_company_id_fk
                       references flow.company
                       on update restrict on delete restrict,
               app_type_id        integer                 not null
                   constraint flow_aa_app_type_id_fk
                       references flow.app_type
                       on update restrict on delete restrict,
               attachment_type_id integer                 not null
                   constraint flow_aa_attachment_type_id_fk
                       references flow.attachment_type
                       on update restrict on delete restrict,
               filename           varchar(1000),
               content_type       varchar(100),
               s3_key             varchar(100),
               size               integer,
               show               boolean   default false not null,
               date_created       timestamp default now(),
               date_modified      timestamp,
               created_by_id      integer                 not null
                   constraint flow_aa_created_by_id_fk
                       references flow."user",
               modified_by_id     integer
                   constraint flow_aa_modified_by_id_fk
                       references flow."user",
               archived           boolean   default false not null,
               version_number     varchar(20),
               build_number       integer,
               display_name       varchar(100),
               beta               boolean default false not null
           )
    """;

  //language=PostgreSQL
  public final static String insertMissingAppRecord = """
           insert into flow.app_attachment (company_id, app_type_id, attachment_type_id, filename, content_type, s3_key, size, date_modified, created_by_id, modified_by_id, version_number, build_number, display_name)
           select 3, :appTypeId, 8, :fileName, :contentType, :s3key, :size, now(), 2417172, 2417172, :versionNumber, :buildNumber, :fileName
           where not exists ( select id
           from flow.app_attachment
             where s3_key = :s3key)
    """;


}
