-- drop FUNCTION if exists flow.get_project_process_step_event_requirements_with_values(INTEGER, INTEGER[]);

CREATE OR REPLACE FUNCTION flow.get_project_process_step_event_requirements_with_values(p_project_process_step_id INTEGER, p_requirement_ids INTEGER[])

  RETURNS TABLE (id int, project_id int, process_step_requirement_type_id int, process_step_id int, operator_type_id int, requirement_value varchar, custom_field_group_assignment_id int,
                 company_function_id int, fail_if_no_reference_step_found boolean, reference_process_step_id int, requirement_nbr int, date_created timestamp, date_modified timestamp, immutable boolean, created_by_id int, modified_by_id int,
                 archived boolean, secondary_requirement_value varchar, data_type_requirement_id int, list_of_value_id int, list_of_value_ids json, operator_type varchar,
                 process_step_requirement_type varchar, parent_id int, custom_value boolean, parent_name varchar, field_name varchar, custom_field_sql_key varchar,
                 company_system_list_id int, system_list_option_id int, custom_sql_option_id int, time_zone varchar, project_custom_field_value_id int, project_process_step_id int, text_value text,
                 date_value date, timestamp_value timestamp, boolean_value boolean, numeric_value numeric, int_value int, int_array_value json, system_list_option_ids json,
                 data_type_requirement json, list_of_value json, list_of_values json, data_type_id int, has_list_values boolean, company_function_name varchar, function_name varchar, requirement_param_dynamic_values json,
                 company_function_params json, available_list_of_values json) AS

$BODY$
BEGIN
  RETURN QUERY
    select
      psr.id,
      pps.project_id,
      psr.process_step_requirement_type_id,
      pse.process_step_id,
      psr.operator_type_id,
      psr.requirement_value,
      psr.custom_field_group_assignment_id,
      psr.company_function_id,
      psr.fail_if_no_reference_step_found,
      psr.reference_process_step_id,
      psr.requirement_nbr,
      psr.date_created,
      psr.date_modified,
      psr.immutable,
      psr.created_by_id,
      psr.modified_by_id,
      psr.archived,
      psr.secondary_requirement_value,
      psr.data_type_requirement_id,
      psr.list_of_value_id,
      array_to_json(psr.list_of_value_ids) as list_of_value_ids,
      ot.operator_type,
      psrt.process_step_requirement_type,
      ps.id as parent_id,
      case when psr.data_type_requirement_id is null then true else false end as custom_value,
      ps.process_step_name as parent_name,
      cf.field_name,
      cf.custom_field_sql_key,
      cf.company_system_list_id,
      psr.system_list_option_id,
      psr.custom_sql_option_id,
      p.time_zone,
      case when pps1.id is not null then ppscfv1.id else ppscfv.id end as project_custom_field_value_id,
      case when pps1.id is not null then ppscfv1.project_process_step_id else ppscfv.project_process_step_id end as "projectprocessStepId",
      case when psr.process_step_requirement_type_id = 1 then
               case when pps1.id is not null then ppscfv1.text_value else ppscfv.text_value end
           when psr.process_step_requirement_type_id = 3 then
               pcfv.text_value
           when psr.process_step_requirement_type_id = 4 then
               ccfv.text_value
          end as "textValue",
      case when psr.process_step_requirement_type_id = 1 then
               case when pps1.id is not null then ppscfv1.date_value else ppscfv.date_value end
           when psr.process_step_requirement_type_id = 3 then
               pcfv.date_value
           when psr.process_step_requirement_type_id = 4 then
               ccfv.date_value
          end as "dateValue",
      case when psr.process_step_requirement_type_id = 1 then
               case when pps1.id is not null then ppscfv1.timestamp_value else ppscfv.timestamp_value end
           when psr.process_step_requirement_type_id = 3 then
               pcfv.timestamp_value
           when psr.process_step_requirement_type_id = 4 then
               ccfv.timestamp_value
          end as "timestampValue",
      case when psr.process_step_requirement_type_id = 1 then
               case when pps1.id is not null then ppscfv1.boolean_value else ppscfv.boolean_value end
           when psr.process_step_requirement_type_id = 3 then
               pcfv.boolean_value
           when psr.process_step_requirement_type_id = 4 then
               ccfv.boolean_value
          end as "booleanValue",
      case when psr.process_step_requirement_type_id = 1 then
               case when pps1.id is not null then ppscfv1.numeric_value else ppscfv.numeric_value end
           when psr.process_step_requirement_type_id = 3 then
               pcfv.numeric_value
           when psr.process_step_requirement_type_id = 4 then
               ccfv.numeric_value
          end as "numericValue",
      case when psr.process_step_requirement_type_id = 1 then
               case when pps1.id is not null then ppscfv1.int_value else ppscfv.int_value end
           when psr.process_step_requirement_type_id = 3 then
               pcfv.int_value
           when psr.process_step_requirement_type_id = 4 then
               ccfv.int_value
          end as "intValue",
      case when psr.process_step_requirement_type_id = 1 then
               case when pps1.id is not null then coalesce(array_to_json(ppscfv1.int_array_value), '[]') else coalesce(array_to_json(ppscfv.int_array_value), '[]') end
           when psr.process_step_requirement_type_id = 3 then
               coalesce(array_to_json(pcfv.int_array_value), '[]')
           when psr.process_step_requirement_type_id = 4 then
               coalesce(array_to_json(ccfv.int_array_value), '[]')
          end as "intArrayValue",
      array_to_json(cf.system_list_option_ids) as system_list_option_ids,
      (select json_build_object(
                'id', dtr.id,
                'dataTypeValue', dtr.data_type_value,
                'secondaryRequirement', dtr.secondary_requirement
                ))                                     as data_type_requirement,
      (select json_build_object(
                'id', lov.id,
                'name', lov.name
                ))                                     as list_of_value,
      coalesce((
                 SELECT array_to_json(array_agg(row_to_json(lov)))
                 FROM (
                        select lv.id,
                               lv.name
                        from flow.list_of_value lv
                        where lv.id = any (psr.list_of_value_ids)
                      ) lov), '[]') AS list_of_values,
      coalesce(cdt.data_type_id, df.return_data_type_id) as data_type_id,
      cdt.has_list_values,
      cfn.company_function_name,
      df.function_name,
      coalesce((
                 SELECT array_to_json(array_agg(row_to_json(params)))
                 FROM (
                        select rpdv.id,
                               rpdv.archived,
                               dfp.db_function_id as "dbFunctionId",
                               dfp.parameter_name as "parameterName",
                               dfp.data_type_id as "dataTypeId",
                               dfp.id as "dbFunctionParamId",
                               rpdv.process_step_event_requirement_id as "processStepRequirementId",
                               rpdv.dynamic_value as "dynamicValue"
                        from flow.db_function_param dfp
                               left join flow.event_requirement_param_dynamic_value rpdv on rpdv.db_function_param_id = dfp.id and rpdv.process_step_event_requirement_id = psr.id
                        where dfp.db_function_id = cfn.db_function_id
                          and dfp.parameter_type_id = 2
                          and rpdv.archived is not true
                      ) params), '[]') AS requirement_param_dynamic_values,
      coalesce((
                 SELECT array_to_json(array_agg(row_to_json(params)))
                 FROM (
                        select dfp.data_type_id as "dataTypeId",
                               dfp.parameter_type_id as "parameterTypeId",
                               dfp.display_order as "displayOrder",
                               ppscfv.text_value as "textValue",
                               ppscfv.date_value as "dateValue",
                               ppscfv.timestamp_value as "timestampValue",
                               ppscfv.boolean_value as "booleanValue",
                               ppscfv.numeric_value as "numericValue",
                               ppscfv.int_value as "intValue",
                               dfp.system_value_id as "systemValueId",
                               rpdv.dynamic_value as "dynamicValue"
                        from flow.db_function_param dfp
                               left join flow.company_function_param cfp on cfp.db_function_param_id = dfp.id and cfp.archived is not true
                               left join flow.system_value sv on sv.id = dfp.system_value_id
                               left join flow.event_requirement_param_dynamic_value rpdv on rpdv.db_function_param_id = dfp.id and rpdv.process_step_event_requirement_id = psr.id
                               left join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = cfp.custom_field_group_assignment_id
                        where dfp.db_function_id = df.id
                          and dfp.archived is not true
                        order by dfp.display_order) params), '[]') AS "companyFunctionParams",
      case when cf.list_of_value_id is not null then
             coalesce((
                        SELECT array_to_json(array_agg(row_to_json(lov)))
                        FROM (
                               select lv.id,
                                      lv.name
                               from flow.list_of_value lv
                               where lv.parent_id = cf.list_of_value_id
                             ) lov), '[]')
           when cf.company_system_list_id is not null then
             coalesce((
                        SELECT array_to_json(array_agg(row_to_json(lov)))
                        FROM (
                               select * from flow.get_system_list_options(cf.company_id, cf.company_system_list_id, true, cf.system_list_option_ids)
                             ) lov), '[]')
           else '[]' end AS available_list_of_values
    from flow.process_step_event_requirement psr
    inner join flow.process_step_event pse on psr.process_step_event_id = pse.id
    inner join flow.operator_type ot on ot.id = psr.operator_type_id
    inner join flow.process_step_requirement_type psrt on psrt.id = psr.process_step_requirement_type_id
    inner join flow.project_process_step pps on pps.process_step_id = pse.process_step_id
    inner join flow.project p on p.id = pps.project_id
    left join flow.custom_field_group_assignment cfga on cfga.id = psr.custom_field_group_assignment_id
    left join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
    left join flow.project_process_step pps1 on pps1.project_id = pps.project_id and pps1.process_step_id = cfg.process_step_id and pps1.main is true and pps1.archived is false
    left join flow.custom_field cf on cf.id = cfga.custom_field_id
    left join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
    left join flow.process_step ps on ps.id = cfg.process_step_id
    left join flow.company_function cfn on cfn.id = psr.company_function_id
    left join flow.db_function df on df.id = cfn.db_function_id
    left join flow.data_type_requirement dtr on dtr.id = psr.data_type_requirement_id
    left join flow.list_of_value lov on lov.id = psr.list_of_value_id
    left join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = cfga.id
    left join flow.project_process_step_custom_field_value ppscfv1 on ppscfv1.custom_field_group_assignment_id = cfga.id and ppscfv1.project_process_step_id = pps1.id
    left join flow.project_custom_field_value pcfv on pcfv.custom_field_group_assignment_id = cfga.id and pcfv.project_id = pps.project_id
    left join flow.contact_custom_field_value ccfv on ccfv.custom_field_group_assignment_id = cfga.id and ccfv.contact_id = p.contact_id
    where
      psr.archived is not true and
      cfga.archived is not true and
      pps.id = p_project_process_step_id and
      psr.id = any (array[p_requirement_ids]::int[])
    order by psr.requirement_nbr;

END;
$BODY$
LANGUAGE plpgsql
VOLATILE
COST 100
ROWS 1000;
