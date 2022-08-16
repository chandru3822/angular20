-- DROP FUNCTION IF EXISTS flow.get_attachment_compare_fields_for_object(integer, int, int);
CREATE OR REPLACE FUNCTION flow.get_attachment_compare_fields_for_object(p_attachment_id INTEGER, p_source_id int, p_object_type_id integer)

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
  v_attachment_type_id                  int;
  v_object_reference_attachment_type_id int;
BEGIN

  case when p_object_type_id = 1 then
    select a.attachment_type_id, pat.id
    into v_attachment_type_id, v_object_reference_attachment_type_id
    from flow.attachment a
           inner join flow.attachment_type att on a.attachment_type_id = att.id
           inner join flow.project_attachment_type pat on att.id = pat.attachment_type_id and pat.archived is false
    where a.id = p_attachment_id;
    return query
      select null::int                                                      as custom_field_id,
             cf.id                                                          as ancillary_custom_field_id,
             cf.field_name,
             cdt.data_type_id,
             null::int                                                      as default_field_id,
             p_attachment_id                                                as attachment_id,
             p_object_type_id                                               as object_type_id,
             pcfv.project_id                                                as project_id,
             cfga.id                                                        as custom_field_group_assignment_id,
             pcfv.text_value,
             pcfv.int_value,
             coalesce(array_to_json(pcfv.int_array_value), '[]')::json      as int_array_value,
             pcfv.date_value,
             pcfv.timestamp_value,
             pcfv.boolean_value,
             pcfv.numeric_value,
             pcfv.rich_text_value,
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
                                      (lov.archived is true AND (lov.id = pcfv.int_value)
                                        OR lov.id = any (pcfv.int_array_value)))
                               order by case when cf.sort_list_values_alphabetically is true then lov.name end,
                                        case when cf.sort_list_values_alphabetically is false then lov.display_order end
                             ) listOfValues), '[]')                         AS "listOfValues",
             coalesce(array_to_json(cf.system_list_option_ids), '[]')::json as system_list_option_ids
      from flow.project_custom_field_value pcfv
             inner join flow.custom_field_group_assignment cfga on pcfv.custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field_group_assignment cfga2
                        on cfga2.ancillary_custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field cf on cfga.custom_field_id = cf.id
             inner join flow.custom_field_group cfg on cfga2.custom_field_group_id = cfg.id and
                                                       cfg.project_attachment_type_id =
                                                       v_object_reference_attachment_type_id
             inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
      where pcfv.project_id = p_source_id
        and cfga.archived is false
        and cfga2.archived is false;
    when p_object_type_id = 4 then
      select a.attachment_type_id, pat.id
      into v_attachment_type_id, v_object_reference_attachment_type_id
      from flow.attachment a
             inner join flow.attachment_type att on a.attachment_type_id = att.id
             inner join flow.process_step_attachment_type pat
                        on att.id = pat.attachment_type_id and pat.archived is false
      where a.id = p_attachment_id
        and pat.process_step_id = (select process_step_id
                                   from flow.project_process_step
                                   where id = p_source_id);

      return query
        select null::int                                                      as custom_field_id,
               cf.id                                                          as ancillary_custom_field_id,
               cf.field_name,
               cdt.data_type_id,
               null::int                                                      as default_field_id,
               p_attachment_id                                                as attachment_id,
               p_object_type_id                                               as object_type_id,
               pps.project_id                                                 as project_id,
               cfga.id                                                        as custom_field_group_assignment_id,
               ppscfv.text_value,
               ppscfv.int_value,
               coalesce(array_to_json(ppscfv.int_array_value), '[]')::json    as int_array_value,
               ppscfv.date_value,
               ppscfv.timestamp_value,
               ppscfv.boolean_value,
               ppscfv.numeric_value,
               ppscfv.rich_text_value,
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
                                        (lov.archived is true AND (lov.id = ppscfv.int_value)
                                          OR lov.id = any (ppscfv.int_array_value)))
                                 order by case when cf.sort_list_values_alphabetically is true then lov.name end,
                                          case
                                            when cf.sort_list_values_alphabetically is false then lov.display_order end
                               ) listOfValues), '[]')                         AS "listOfValues",
               coalesce(array_to_json(cf.system_list_option_ids), '[]')::json as system_list_option_ids
        from flow.project_process_step_custom_field_value ppscfv
               inner join flow.project_process_step pps on ppscfv.project_process_step_id = pps.id
               inner join flow.custom_field_group_assignment cfga on ppscfv.custom_field_group_assignment_id = cfga.id
               inner join flow.custom_field_group_assignment cfga2
                          on cfga2.ancillary_custom_field_group_assignment_id = cfga.id
               inner join flow.custom_field cf on cfga.custom_field_id = cf.id
               inner join flow.custom_field_group cfg on cfga2.custom_field_group_id = cfg.id and
                                                         cfg.project_attachment_type_id =
                                                         v_object_reference_attachment_type_id
               inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
        where ppscfv.project_process_step_id = p_source_id
          and cfga.archived is false
          and cfga2.archived is false;
    when p_object_type_id = 6 then
      select a.attachment_type_id, pat.id
      into v_attachment_type_id, v_object_reference_attachment_type_id
      from flow.attachment a
             inner join flow.attachment_type att on a.attachment_type_id = att.id
             inner join flow.event_attachment_type pat on att.id = pat.attachment_type_id and pat.archived is false
      where a.id = p_attachment_id
        and pat.event_id = (select pse.event_id
                            from flow.project_process_step_event ppse
                                   inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                            where ppse.id = p_source_id);

      return query
        select null::int                                                      as custom_field_id,
               cf.id                                                          as ancillary_custom_field_id,
               cf.field_name,
               cdt.data_type_id,
               null::int                                                      as default_field_id,
               p_attachment_id                                                as attachment_id,
               p_object_type_id                                               as object_type_id,
               pps.project_id                                                 as project_id,
               cfga.id                                                        as custom_field_group_assignment_id,
               ppsecfv.text_value,
               ppsecfv.int_value,
               coalesce(array_to_json(ppsecfv.int_array_value), '[]')::json   as int_array_value,
               ppsecfv.date_value,
               ppsecfv.timestamp_value,
               ppsecfv.boolean_value,
               ppsecfv.numeric_value,
               ppsecfv.rich_text_value,
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
                                        (lov.archived is true AND (lov.id = ppsecfv.int_value)
                                          OR lov.id = any (ppsecfv.int_array_value)))
                                 order by case when cf.sort_list_values_alphabetically is true then lov.name end,
                                          case
                                            when cf.sort_list_values_alphabetically is false then lov.display_order end
                               ) listOfValues), '[]')                         AS "listOfValues",
               coalesce(array_to_json(cf.system_list_option_ids), '[]')::json as system_list_option_ids
        from flow.project_process_step_event_custom_field_value ppsecfv
               inner join flow.project_process_step_event ppse on ppsecfv.project_process_step_event_id = ppse.id
               inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
               inner join flow.custom_field_group_assignment cfga on ppsecfv.custom_field_group_assignment_id = cfga.id
               inner join flow.custom_field_group_assignment cfga2
                          on cfga2.ancillary_custom_field_group_assignment_id = cfga.id
               inner join flow.custom_field cf on cfga.custom_field_id = cf.id
               inner join flow.custom_field_group cfg on cfga2.custom_field_group_id = cfg.id and
                                                         cfg.project_attachment_type_id =
                                                         v_object_reference_attachment_type_id
               inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
        where cfga.archived is false
          and cfga2.archived is false
          and ppsecfv.project_process_step_event_id = p_source_id
        union all
        select null::int            as custom_field_id,
               null::int            as ancillary_custom_field_id,
               df.field_name,
               df.data_type_id,
               cfga.default_field_id,
               p_attachment_id      as attachment_id,
               p_object_type_id     as object_type_id,
               pps.project_id       as project_id,
               cfga.id              as custom_field_group_assignment_id,
               null::text           as text_value,
               case
                 when df.id = 12 then (select resource_id
                                       from flow.project_process_step_event ppse
                                       where ppse.id = p_source_id)
                 else null::int end as int_value,
               '[]'::json           as int_array_value,
               null::date           as date_value,
               case
                 when df.id = 10 then (select start_time
                                       from flow.project_process_step_event ppse
                                       where ppse.id = p_source_id)
                 when df.id = 11 then (select end_time
                                       from flow.project_process_step_event ppse
                                       where ppse.id = p_source_id)
                 else null::timestamp end,
               null::boolean        as boolean_value,
               null::numeric        as numeric_value,
               null::text           as rich_text_value,
               false                as has_list_value,
               null                 as custom_field_sql_key,
               null                 as company_system_list_id,
               '[]'::json           as list_of_values,
               '[]'::json           as system_list_option_ids
        from flow.custom_field_group_assignment cfga
               inner join flow.default_field df on cfga.default_field_id = df.id
               inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
               inner join flow.event_attachment_type eat on cfg.event_attachment_type_id = eat.id
               inner join flow.process_step_event pse on pse.event_id = eat.event_id
               inner join flow.project_process_step_event ppse
                          on ppse.process_step_event_id = pse.id and ppse.id = p_source_id
               inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
        where cfga.archived is false
          and cfg.archived is false;
    end case;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
