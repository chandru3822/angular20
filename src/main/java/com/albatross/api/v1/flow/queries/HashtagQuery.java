package com.albatross.api.v1.flow.queries;

public class HashtagQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select h.id,
           hashtag,
           hashtag_type_id,
           company_id,
           ht.hashtag_type,
           ht.is_system,
           h.archived
    from flow.hashtag h
      inner join flow.hashtag_type ht on ht.id = h.hashtag_type_id
    where company_id = :companyId
    and h.archived is false
    """;

  //language=PostgreSQL
  public final static String getOne = """
    select h.id,
           hashtag,
           hashtag_type_id,
           company_id,
           ht.hashtag_type,
           ht.is_system,
           h.archived
    from flow.hashtag h
      inner join flow.hashtag_type ht on ht.id = h.hashtag_type_id
    where h.id = :id
    and h.archived is false
    """;

  //language=PostgreSQL
  public final static String update = """
    update flow.hashtag t
    set hashtag = :hashtag,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insert = """
    insert into flow.hashtag (hashtag, hashtag_type_id, company_id, created_by_id)
    values (:hashtag, :hashtagTypeId, :companyId, :userId)
    """;

  //language=PostgreSQL
  public final static String delete = """
    update flow.hashtag t
    set archived = true,
        modified_by_id = :userId,
        date_modified = now()
    where id = :hashtagId
    """;

}
