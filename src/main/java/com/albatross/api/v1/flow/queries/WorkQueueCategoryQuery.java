package com.albatross.api.v1.flow.queries;

public class WorkQueueCategoryQuery {

  //language=PostgreSQL
  public final static String getCategoriesForCompany = """
    select id,
          company_id,
          work_queue_category,
          archived,
          color,
          display_order,
          hidden,
          coalesce((
                                  SELECT array_to_json(array_agg(row_to_json(wlp)))
                                  FROM (
                                           SELECT wlp.id,
                                                  wlp.position_id as "positionId",
                                                  wlp.custom_field_group_assignment_id as "custom_field_group_assignment_id",
                                                  wlp.created_by_id as "createdById",
                                                  wlp.modified_by_id as "modifiedById",
                                                  wlp.archived
                                           FROM flow.white_listed_position wlp
                                           WHERE wlp.white_list_type_id = 11
                                             AND wlp.archived is not true
                                             AND wlp.work_queue_category_id = wqc.id) wlp), '[]') AS "hiddenWhiteListedPositions"
        from flow.work_queue_category wqc
        where company_id = :companyId
          and archived is not true
          and case when wqc.hidden and not :hiddenWqcOverride and :filtered
            then array[ :positionIds ]::bigint[] && (select array_agg(wlp.position_id)
                                                  FROM flow.white_listed_position wlp
                                                  WHERE wlp.white_list_type_id = 11
                                                    AND wlp.archived is not true
                                                    AND wlp.work_queue_category_id = wqc.id)::bigint[] else 1=1 end
        order by display_order
        """;

  //language=PostgreSQL
  public final static String getCategory = """
    select id,
         company_id,
         work_queue_category,
         archived,
         color,
         display_order
       from flow.work_queue_category
       where id = :id
       """;

  //language=PostgreSQL
  public final static String deleteCategory = """
    update flow.work_queue_category
    set archived = true,
      modified_by_id = :modifiedById,
      date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String saveHidden = """
      update flow.work_queue_category
      set hidden = :hidden,
          modified_by_id = :userId,
          date_modified = now()
      where id = :wqcId
    """;

  //language=PostgreSQL
  public final static String archiveWhiteListPositions = """
    update flow.white_listed_position
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where work_queue_category_id = :wqcId
      and company_id = :companyId
      and white_list_type_id = :whiteListTypeId
    """;

  //language=PostgreSQL
  public final static String insertWhiteListPosition = """
    insert into flow.white_listed_position(position_id, work_queue_category_id, white_list_type_id, company_id, created_by_id, date_created, modified_by_id, date_modified)
    select :positionId, :wqcId, :whiteListTypeId, :companyId, :userId, now(), :userId, now()
    where not exists (  select id
                        from flow.white_listed_position
                        where work_queue_category_id = :wqcId
                          and position_id = :positionId
                          and company_id = :companyId
                          and white_list_type_id = :whiteListTypeId
                           and archived is not true)
    """;

  //language=PostgreSQL
  public final static String archiveWhiteListPositionsNoLongerUsed = """
    update flow.white_listed_position
      set archived = true,
          date_modified = now(),
          modified_by_id = :userId
    where work_queue_category_id = :wqcId
      and position_id not in (:positionIdsUsed)
      and company_id = :companyId
      and white_list_type_id = :whiteListTypeId
    """;

  //language=PostgreSQL
  public final static String updateCategory = """
    update flow.work_queue_category
    set work_queue_category = :workQueueCategory,
        color = :color,
        date_modified = now(),
        modified_by_id = :modifiedById,
        display_order = :displayOrder
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertCategory = """
    insert into flow.work_queue_category(company_id, work_queue_category, color, display_order, created_by_id, date_created, modified_by_id, date_modified)
      values (:companyId, :workQueueCategory, :color, (select coalesce(max(display_order) + 1, 0) from flow.work_queue_category where archived is not true), :createdById, now(), :createdById, now())
        """;

}
