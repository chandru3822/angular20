package com.albatross.api.v1.flow.queries;

public class ObjectCategoryQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select id,
      object_category as name,
      object_category_code as code,
      is_default
    from flow.object_category
      where archived is false
        and case when :objectTypeId is null then true else object_type_id = :objectTypeId end
    """;

  //language=PostgreSQL
  public final static String getChildren = """
    select child_object_category_id as id,
        oc.object_category as name
    from flow.object_category_child_object_category coc
        inner join flow.object_category oc on oc.id = coc.child_object_category_id
    where coc.archived is false
      and coc.object_category_id = :parentObjectCategoryId
    """;
}
