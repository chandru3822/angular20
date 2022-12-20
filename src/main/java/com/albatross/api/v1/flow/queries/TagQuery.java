package com.albatross.api.v1.flow.queries;

public class TagQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select id,
           tag_name,
           tag_type_id,
           font_color,
           company_id,
           bg_color,
           archived
    from flow.tag t
    where tag_type_id = :tagTypeId
      and company_id = :companyId
    and archived is false
    """;

  //language=PostgreSQL
  public final static String getOne = """
    select id,
           tag_name,
           tag_type_id,
           font_color,
           company_id,
           bg_color,
           archived
    from flow.tag t
    where id = :id
    and archived is false
    """;

  //language=PostgreSQL
  public final static String update = """
    update flow.tag t
    set tag_name = :tagName,
        bg_color = :bgColor,
        font_color = :fontColor,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insert = """
    insert into flow.tag (tag_name, tag_type_id, bg_color, font_color, company_id, created_by_id)
    values (:tagName, :tagTypeId, :bgColor, :fontColor, :companyId, :userId)
    """;

  //language=PostgreSQL
  public final static String delete = """
    update flow.tag t
    set archived = true,
        modified_by_id = :userId,
        date_modified = now()
    where id = :tagId
    """;

  //language=PostgreSQL
  public final static String projectTags = """
    select pt.id,
           pt.project_id,
           pt.tag_id,
           t.tag_name,
           t.bg_color,
           t.font_color,
           pt.archived
    from flow.project_tag pt
      inner join flow.tag t on t.id = pt.tag_id
    where pt.project_id = :projectId
    and pt.archived is false
    """;
}
