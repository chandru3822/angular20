package com.albatross.api.v1.flow.queries;

public class SecondaryKeyPatternQuery {

  //language=PostgreSQL
  public final static String getByAttachmentTypeId = """
    select atskp.attachment_type_id,
           kp.key_pattern
        from flow.key_pattern kp
        inner join flow.attachment_type_secondary_key_pattern atskp on atskp.secondary_key_pattern_id = kp.id
          where atskp.attachment_type_id = :attachmentTypeId
            and atskp.archived = false
    """;

  //language=PostgreSQL
  public final static String archive = """
    update flow.attachment_type_secondary_key_pattern
      set archived = true
    where attachment_type_id = :attachmentTypeId
        and secondary_key_pattern_id = :secondaryKeyPatternId
    """;

  //language=PostgreSQL
  public final static String insert = """
    insert into flow.attachment_type_secondary_key_pattern (attachment_type_id, secondary_key_pattern_id)
    values (:attachmentTypeId, :secondaryKeyPatternId)
    """;
}
