package com.albatross.api.v1.flow.queries;

public class ObjectTypeTabQuery {

  //language=PostgreSQL
  public final static String getProjectTabs = """
    select cott.id,
           cott.tab_name,
           cott.company_object_type_id,
           cot.object_type_id,
           cott.display_order,
           cott.archived,
           concat('tab_',cott.id) as unique_identifier
    from flow.company_object_type_tab cott
        inner join flow.company_object_type cot on cot.id = cott.company_object_type_id
    where cot.object_type_id = :objectTypeId
        and cot.company_id = :companyId
        and cott.archived is not true
    order by cott.display_order
    """;

  //language=PostgreSQL
  public final static String getTab = """
    select cott.id,
           cott.tab_name,
           cott.display_order,
           cott.company_object_type_id,
           cot.object_type_id,
           cott.archived
    from flow.company_object_type_tab cott
        inner join flow.company_object_type cot on cot.id = cott.company_object_type_id
    where cott.id = :id
    """;

  //language=PostgreSQL
  public final static String updateTab = """
    update flow.company_object_type_tab
        set tab_name = :tabName,
            modified_by_id = :userId,
            date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteTab = """
    update flow.company_object_type_tab
        set archived = true,
            modified_by_id = :userId,
            date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String updateTabDisplayOrder = """
    update flow.company_object_type_tab
        set display_order = :displayOrder,
            modified_by_id = :userId,
            date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertTab = """
    insert into flow.company_object_type_tab(tab_name, display_order, company_object_type_id, date_created, created_by_id)
    select :tabName,
           (select coalesce(max(display_order) + 1, 0) from flow.company_object_type_tab cott
                inner join flow.company_object_type cot on cot.id = cott.company_object_type_id
                where cot.company_id = :companyId and cot.object_type_id = :objectTypeId),
           (select cot.id
                from flow.company_object_type cot
                where cot.company_id = :companyId and cot.object_type_id = :objectTypeId),
           now(),
           :userId
    """;

}
