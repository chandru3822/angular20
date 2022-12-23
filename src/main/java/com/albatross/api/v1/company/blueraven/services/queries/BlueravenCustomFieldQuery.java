package com.albatross.api.v1.company.blueraven.services.queries;

public class BlueravenCustomFieldQuery {

  //language=PostgreSQL
  public final static String getOne = """
    select cf.id,
           cf.list_of_value_id,
           cf.field_name,
           cf.archived,
           cf.sort_list_values_alphabetically,
           cf.created_by_id,
           cf.modified_by_id,
           cf.company_data_type_id,
           cf.company_system_list_id,
           cf.sort_list_values_alphabetically as "sortListValuesAlphabetically",
           array_to_json(cf.system_list_option_ids) as system_list_option_ids,
           cf.lazy_load_values,
           cf.flow_custom_field_id,
           cf.custom_field_sql_key,
           cf.custom_field_sql,
           cf.custom_field_sql_smartlist,
           cf.custom_field_sql_reference_table,
           coalesce((
                      select array_to_json(array_agg(rows))
                      from (
                             select lv.id,
                                    lv.name,
                                    lv.parent_id as "parentId",
                                    lv.date_created as "dateCreated",
                                    lv.date_modified as "dateModified",
                                    lv.created_by_id as "createdById",
                                    lv.modified_by_id as "modifiedById",
                                    lv.display_order as "displayOrder",
                                    lv.archived
                             from brs.list_of_value lv
                             where lv.parent_id = cf.list_of_value_id
                               and lv.archived is not true
                             order by
                               case when cf.sort_list_values_alphabetically is true  then lv.name end,
                               case when cf.sort_list_values_alphabetically is false then lv.display_order end
                           ) rows), '[]') AS list_of_values
    from brs.custom_field cf
    where cf.id = :id
    order by cf.field_name
    """;

  //language=PostgreSQL
  public final static String getAll = """
    select cf.id,
           cf.list_of_value_id,
           cf.field_name,
           cf.archived,
           cf.sort_list_values_alphabetically,
           cf.created_by_id,
           cf.modified_by_id,
           cf.company_data_type_id,
           cf.company_system_list_id,
           array_to_json(cf.system_list_option_ids) as system_list_option_ids,
           cf.lazy_load_values,
           cf.flow_custom_field_id,
           cf.custom_field_sql_key,
           cf.custom_field_sql,
           cf.custom_field_sql_smartlist,
           cf.custom_field_sql_reference_table,
           cf.sort_list_values_alphabetically as "sortListValuesAlphabetically",
           coalesce((
                      select array_to_json(array_agg(rows))
                      from (
                             select lv.id,
                                    lv.name,
                                    lv.parent_id as "parentId",
                                    lv.date_created as "dateCreated",
                                    lv.date_modified as "dateModified",
                                    lv.created_by_id as "createdById",
                                    lv.modified_by_id as "modifiedById",
                                    lv.display_order as "displayOrder",
                                    lv.archived
                             from brs.list_of_value lv
                             where lv.parent_id = cf.list_of_value_id
                               and lv.archived is not true
                             order by
                               case when cf.sort_list_values_alphabetically is true  then lv.name end,
                               case when cf.sort_list_values_alphabetically is false then lv.display_order end
                           ) rows), '[]') AS list_of_values
    from brs.custom_field cf
    where cf.archived is not true
    order by cf.field_name
    """;

  //language=PostgreSQL
  public final static String getGroupsUsingField = """
    select cf.id,
           cf.field_name,
           cfg.group_name,
           ot.object_type
    from brs.custom_field_group cfg
           inner join brs.custom_field_group_assignment cfga on cfga.custom_field_group_id = cfg.id
           inner join brs.custom_field cf on cf.id = cfga.custom_field_id
           inner join brs.object_type ot on ot.id = cfg.object_type_id
    where cf.id = :fieldId
      and cfg.archived is not true
      and cfga.archived is not true
    order by ot.object_type, cfg.group_name, cf.field_name
    """;

  //language=PostgreSQL
  public final static String deleteField = """
    update brs.custom_field
      set archived = true,
      modified_by_id = :modifiedById,
      date_modified = now()
    where id = :fieldId
    """;

  //language=PostgreSQL
  public final static String saveField = """
    update brs.custom_field
    set field_name = trim(:fieldName),
        lazy_load_values = :lazyLoadValues,
        company_system_list_id = :systemListId,
        sort_list_values_alphabetically = :sortListValuesAlphabetically,
        system_list_option_ids = :systemListOptionIds::bigint[],
        custom_field_sql = :customFieldSql,
        custom_field_sql_reference_table = :customFieldSqlReferenceTable,
        flow_custom_field_id = :flowCustomFieldId,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertField = """
    insert into brs.custom_field(list_of_value_id, field_name, company_data_type_id, custom_field_sql, custom_field_sql_reference_table, company_system_list_id, system_list_option_ids, lazy_load_values, flow_custom_field_id, date_created, created_by_id, date_modified, modified_by_id)
    values (:listOfValueId, trim(:fieldName), :companyDataTypeId, :customFieldSql, :customFieldSqlReferenceTable, :systemListId, :listOptionIds, :lazyLoadValues, :flowCustomFieldId, now(), :createdById, now(), :createdById)
    returning id
    """;

  //language=PostgreSQL
  public final static String insertListOfValue = """
    insert into brs.list_of_value(name, parent_id,  display_order, date_created, created_by_id, date_modified, modified_by_id)
    values (trim(:name), :parentId, (select coalesce(max(display_order) + 1, 0) from brs.list_of_value where parent_id = :parentId and archived is not true), now(), :createdById, now(), :createdById)
    """;

  //language=PostgreSQL
  public final static String insertManagementCompany = """
     insert into brs.list_of_value(name, parent_id,  display_order, date_created, created_by_id, date_modified, modified_by_id)
     values (trim(:name), (select list_of_value_id from brs.custom_field cf where cf.field_name = 'Management Company'), (select coalesce(max(display_order) + 1, 0) from brs.list_of_value where parent_id = (select list_of_value_id from brs.custom_field cf where cf.field_name = 'Management Company') and archived is not true), now(), :createdById, now(), :createdById);
    """;

  //language=PostgreSQL
  public final static String getListOfValueIdByName = """
    select id from brs.list_of_value where name = trim(:name);
    """;

  //language=PostgreSQL
  public final static String updateListOfValue = """
    update brs.list_of_value
    set name = trim(:name),
        parent_id = :parentId,
        modified_by_id = :modifiedById,
        display_order = :displayOrder,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String archiveListOfValue = """
    update brs.list_of_value
    set archived = true,
      modified_by_id = :modifiedById,
      date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getByObjectCode = """
    select cf.id,
           cf.list_of_value_id,
           cf.field_name,
           cf.field_code,
           cf.sort_list_values_alphabetically as "sortListValuesAlphabetically",
           cf.company_system_list_id,
           array_to_json(cf.system_list_option_ids) as system_list_option_ids,
           cf.lazy_load_values,
           cf.custom_field_sql_key,
           cf.custom_field_sql,
           cf.custom_field_sql_smartlist,
           cf.flow_custom_field_id,
           cfga.id                          as custom_field_group_assignment_id,
           cfga.field_order,
           cfga.required,
           cfga.min_value,
           cfga.max_value,
           cdt.data_type_id,
           cdt.has_list_values,
           cfg.group_name,
           cfg.group_order,
           cdt.allow_multiple,
           dt.id as data_type_id,
           dt.data_type,
           ot.object_code,
           coalesce((
                        select array_to_json(array_agg(rows))
                        from (
                                 select lv.id,
                                        lv.name,
                                        lv.parent_id      as "parentId",
                                        lv.date_created   as "dateCreated",
                                        lv.date_modified  as "dateModified",
                                        lv.created_by_id  as "createdById",
                                        lv.modified_by_id as "modifiedById",
                                        lv.display_order  as "displayOrder",
                                        lv.archived
                                 from brs.list_of_value lv
                                 where lv.parent_id = cf.list_of_value_id
                                   and lv.archived is not true
                                 order by
                                   case when cf.sort_list_values_alphabetically is true  then lv.name end,
                                   case when cf.sort_list_values_alphabetically is false then lv.display_order end
                             ) rows), '[]') AS list_of_values
    from brs.custom_field cf
             inner join brs.custom_field_group_assignment cfga
                        on cf.id = cfga.custom_field_id
             inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
             inner join brs.object_type ot on cfg.object_type_id = ot.id
             inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
             inner join flow.data_type dt on cdt.data_type_id = dt.id
    where cfga.archived is false
      and cfg.archived is false
      and cf.archived is false
      and ot.object_code = :objectCode
    order by cfga.field_order, cf.field_name
    """;
}
