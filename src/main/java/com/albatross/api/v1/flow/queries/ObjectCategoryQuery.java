package com.albatross.api.v1.flow.queries;

public class ObjectCategoryQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select id,
      object_category as name,
      object_category_code as code
    from flow.object_category
      where archived is false
        and case when :objectTypeId is null then true else object_type_id = :objectTypeId end
    """;
}
