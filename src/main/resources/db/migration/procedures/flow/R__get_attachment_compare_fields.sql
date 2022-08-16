-- DROP FUNCTION IF EXISTS flow.get_attachment_compare_fields(integer);
CREATE OR REPLACE FUNCTION flow.get_attachment_compare_fields(p_attachment_id INTEGER)

  RETURNS TABLE
          (
            custom_field_id                  int,
            ancillary_custom_field_id        int,
            field_name                       character varying,
            data_type_id                     int,
            default_field_id                 int,
            attachment_id                    int,
            object_type_id                   int,
            project_id                       int,
            custom_field_group_assignment_id int,
            text_value                       text,
            int_value                        int,
            int_array_value                  json,
            date_value                       date,
            timestamp_value                  timestamp,
            boolean_value                    boolean,
            numeric_value                    numeric(10, 2),
            rich_text_value                  text,
            has_list_values                  boolean,
            custom_field_sql_key             character varying,
            company_system_list_id           int,
            list_of_values                   json,
            system_list_option_ids           json
          )
AS

$BODY$
declare
  v_source_id      int;
  v_object_type_id int;
BEGIN

  select gao.object_type_id, gao.source_id
  into v_object_type_id, v_source_id
  from flow.get_attachment_origin(p_attachment_id) gao;

  return query
    --native fields, always use this query
    select cf.id                                                     as custom_field_id,
           null::int                                                 as ancillary_custom_field_id,
           cf.field_name,
           cdt.data_type_id,
           null::int                                                 as default_field_id,
           a.id                                                      as attachment_id,
           v_object_type_id                                          as object_type_id,
           null::int                                                 as project_id,
           cfga.id                                                   as custom_field_group_assignment_id,
           acfv.text_value,
           acfv.int_value,
           coalesce(array_to_json(acfv.int_array_value), '[]')::json as int_array_value,
           acfv.date_value,
           acfv.timestamp_value,
           acfv.boolean_value,
           acfv.numeric_value,
           acfv.rich_text_value,
           cdt.has_list_values,
           cf.custom_field_sql_key,
           cf.company_system_list_id,
           coalesce((
                      SELECT array_to_json(array_agg(row_to_json(listOfValues)))
                      FROM (
                             select lov.id,
                                    lov.name,
                                    lov.code,
                                    lov.parent_id,
                                    lov.display_order,
                                    lov.archived
                             from flow.list_of_value lov
                             where lov.parent_id is not null
                               and lov.parent_id = cf.list_of_value_id
                               and (lov.archived is not true OR
                                    (lov.archived is true AND (lov.id = acfv.int_value)
                                      OR lov.id = any (acfv.int_array_value)))
                             order by case when cf.sort_list_values_alphabetically is true then lov.name end,
                                      case when cf.sort_list_values_alphabetically is false then lov.display_order end
                           ) listOfValues), '[]')                    AS "listOfValues",
           array_to_json(cf.system_list_option_ids)::json            as system_list_option_ids
    from flow.attachment a
           inner join flow.custom_field_group cfg on cfg.attachment_type_id = a.attachment_type_id
           inner join flow.custom_field_group_assignment cfga on cfg.id = cfga.custom_field_group_id
           inner join flow.custom_field cf on cfga.custom_field_id = cf.id
           inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
           left join flow.attachment_custom_field_value acfv
                     on a.id = acfv.attachment_id and acfv.custom_field_group_assignment_id = cfga.id
    where a.id = p_attachment_id
      and cfg.archived is false
      and cfga.archived is false
    union all
    select *
    from flow.get_attachment_compare_fields_for_object(p_attachment_id, v_source_id, v_object_type_id)
    order by field_name;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
