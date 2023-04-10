 drop FUNCTION if exists flow.get_project_process_step_event_requirements_with_values(bigint, bigint[]);

CREATE OR REPLACE FUNCTION flow.get_project_process_step_event_requirements_with_values(p_project_process_step_id bigint, p_requirement_ids bigint[])

  RETURNS TABLE (id bigint, project_id bigint, process_step_requirement_type_id bigint, process_step_id bigint,
                 operator_type_id bigint, requirement_value varchar, custom_field_group_assignment_id bigint,
                 company_function_id bigint, fail_if_no_reference_step_found boolean, reference_process_step_id bigint,
                 requirement_nbr bigint, date_created timestamp, date_modified timestamp, immutable boolean, created_by_id bigint,
                 modified_by_id bigint,
                 archived boolean, secondary_requirement_value varchar, data_type_requirement_id bigint, list_of_value_id bigint,
                 list_of_value_ids json, operator_type varchar,
                 process_step_requirement_type varchar, parent_id bigint, custom_value boolean, field_name varchar,
                 custom_field_sql_key varchar, custom_field_sql text, custom_field_sql_smartlist text,
                 company_system_list_id bigint, system_list_option_id bigint, custom_sql_option_id bigint, time_zone varchar,
                 system_list_option_ids json,
                 list_of_value json, list_of_values json, data_type_id bigint, has_list_values boolean, company_function_name varchar,
                 function_name varchar, requirement_param_dynamic_values json,
                 company_function_params json, available_list_of_values json, main_project_process_step_id bigint, contact_id bigint,
                 data_view_field_config_id int, data_view_child_field_config_id int,
                 data_view_field_name varchar, data_view_child_field_name varchar, data_type_requirement json, parent_name varchar,
                 project_process_step_id bigint,
                 text_value text, date_value date, timestamp_value timestamp, boolean_value boolean, numeric_value numeric,
                 int_value bigint, int_array_value json) AS

$BODY$
BEGIN
  RETURN QUERY
    with reqs as (select
                    psr.id::bigint,
                    pps.project_id::bigint,
                    psr.process_step_requirement_type_id::bigint,
                    pse.process_step_id::bigint,
                    psr.operator_type_id::bigint,
                    psr.requirement_value,
                    psr.custom_field_group_assignment_id::bigint,
                    psr.company_function_id::bigint,
                    psr.fail_if_no_reference_step_found,
                    psr.reference_process_step_id::bigint,
                    psr.requirement_nbr::bigint,
                    psr.date_created,
                    psr.date_modified,
                    psr.immutable,
                    psr.created_by_id::bigint,
                    psr.modified_by_id::bigint,
                    psr.archived,
                    psr.secondary_requirement_value,
                    psr.data_type_requirement_id::bigint,
                    psr.list_of_value_id::bigint,
                    array_to_json(psr.list_of_value_ids) as list_of_value_ids,
                    ot.operator_type,
                    psrt.process_step_requirement_type,
                    cfg.process_step_id::bigint                                             as parent_id,
                    case when psr.data_type_requirement_id is null then true else false end as custom_value,
                    cf.field_name,
                    cf.custom_field_sql_key,
                    cf.custom_field_sql,
                    cf.custom_field_sql_smartlist,
                    cf.company_system_list_id::bigint,
                    psr.system_list_option_id::bigint,
                    psr.custom_sql_option_id::bigint,
                    p.time_zone,
                    pps.id::bigint as project_process_step_id,
                    array_to_json(cf.system_list_option_ids) as system_list_option_ids,
                    (select json_build_object(
                              'id', lov.id,
                              'name', lov.name
                              ) from flow.list_of_value lov
                     where lov.id = psr.list_of_value_id)                                                            as list_of_value,
                    coalesce((
                               SELECT array_to_json(array_agg(row_to_json(lov)))
                               FROM (
                                      select lv.id,
                                             lv.name
                                      from flow.list_of_value lv
                                      where lv.id = any (psr.list_of_value_ids)
                                    ) lov), '[]') AS list_of_values,
                    case
                      when psr.process_step_requirement_type_id = 12 and psr.data_view_child_field_config_id is not null
                        then (select ubt.return_data_type_id from flow.unique_behavior_type ubt where ubt.id = dvcfc.unique_behavior_type_id)
                      when psr.process_step_requirement_type_id = 12 and psr.data_view_field_config_id is not null and
                           def.data_type_id is not null then def.data_type_id
                      when psr.process_step_requirement_type_id = 12 and psr.data_view_field_config_id is not null and
                           def.data_type_id is null
                        then (select f.company_data_type_id
                              from flow.custom_field_group_assignment c
                                     inner join flow.custom_field f on f.id = c.custom_field_id
                                     inner join flow.company_data_type t on t.id = f.company_data_type_id
                              where c.id = dvfc.custom_field_group_assignment_id)
                      else coalesce(cdt.data_type_id, df.return_data_type_id)::bigint end   as data_type_id,
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
                         else '[]' end AS available_list_of_values,
                    (select pps1.id
                     from flow.project_process_step pps1
                     where pps1.project_id = pps.project_id
                       and pps1.process_step_id = cfg.process_step_id
                       and pps1.main is true
                       and pps1.archived is false
                    )::bigint as main_project_process_step_id,
                    p.contact_id,
                    psr.data_view_field_config_id,
                    psr.data_view_child_field_config_id,
                    dvfc.display_name                                                       as data_view_field_name,
                    dvcfc.display_name                                                      as data_view_child_field_name
                  from flow.process_step_event_requirement psr
                         inner join flow.process_step_event pse on psr.process_step_event_id = pse.id
                         inner join flow.operator_type ot on ot.id = psr.operator_type_id
                         inner join flow.process_step_requirement_type psrt on psrt.id = psr.process_step_requirement_type_id
                         inner join flow.project_process_step pps on pps.process_step_id = pse.process_step_id
                         inner join flow.project p on p.id = pps.project_id
                         left join flow.custom_field_group_assignment cfga on cfga.id = psr.custom_field_group_assignment_id
                         left join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                         left join flow.custom_field cf on cf.id = cfga.custom_field_id
                         left join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
                         left join flow.company_function cfn on cfn.id = psr.company_function_id
                         left join flow.db_function df on df.id = cfn.db_function_id
                         left join flow.data_view_field_config dvfc on dvfc.id = psr.data_view_field_config_id
                         left join flow.default_field def on def.id = dvfc.default_field_id
                         left join flow.data_view_child_field_config dvcfc on dvcfc.id = psr.data_view_child_field_config_id
                  where
                    psr.archived is not true
                    and cfga.archived is not true
                    and pps.id = p_project_process_step_id
                    and psr.id = any (array[p_requirement_ids]::bigint[]))
--                     and pps.id = 6372993
--                     and psr.id = any (array[545]::bigint[])
    select     r.id,
               r.project_id,
               r.process_step_requirement_type_id,
               r.process_step_id,
               r.operator_type_id,
               r.requirement_value,
               r.custom_field_group_assignment_id,
               r.company_function_id,
               r.fail_if_no_reference_step_found,
               r.reference_process_step_id,
               r.requirement_nbr,
               r.date_created,
               r.date_modified,
               r.immutable,
               r.created_by_id,
               r.modified_by_id,
               r.archived,
               r.secondary_requirement_value,
               r.data_type_requirement_id,
               r.list_of_value_id,
               r.list_of_value_ids,
               r.operator_type,
               r.process_step_requirement_type,
               r.parent_id,
               r.custom_value,
               r.field_name,
               r.custom_field_sql_key,
               r.custom_field_sql,
               r.custom_field_sql_smartlist,
               r.company_system_list_id,
               r.system_list_option_id,
               r.custom_sql_option_id,
               r.time_zone,
               r.system_list_option_ids,
               r.list_of_value,
               r.list_of_values,
               r.data_type_id,
               r.has_list_values,
               r.company_function_name,
               r.function_name,
               r.requirement_param_dynamic_values,
               r."companyFunctionParams",
               r.available_list_of_values,
               r.main_project_process_step_id,
               r.contact_id,
               r.data_view_field_config_id,
               r.data_view_child_field_config_id,
               r.data_view_field_name,
               r.data_view_child_field_name,
               (select json_build_object(
                         'id', dtr.id,
                         'dataTypeValue', dtr.data_type_value,
                         'secondaryRequirement', dtr.secondary_requirement)
                from flow.data_type_requirement dtr where dtr.id = r.data_type_requirement_id  )  as data_type_requirement,
               (select ps.process_step_name from flow.process_step ps where ps.id = r.parent_id) as parent_name,
               coalesce(r.main_project_process_step_id, r.project_process_step_id)::bigint as "projectprocessStepId",
               case when r.data_type_id = 5 or r.data_type_id = 13 then
                      case when r.process_step_requirement_type_id = 1 then
                             case when r.main_project_process_step_id is not null then
                                    (select ppscfv1.text_value from flow.project_process_step_custom_field_value ppscfv1 where ppscfv1.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ppscfv1.project_process_step_id = r.main_project_process_step_id)
                                  else (select ppscfv.text_value from flow.project_process_step_custom_field_value ppscfv where ppscfv.project_process_step_id = r.project_process_step_id and ppscfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id) end
                           when r.process_step_requirement_type_id = 3 then
                             (select pcfv.text_value from flow.project_custom_field_value pcfv where pcfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and pcfv.project_id = r.project_id)
                           when r.process_step_requirement_type_id = 4 then
                             (select ccfv.text_value from flow.contact_custom_field_value ccfv where ccfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ccfv.contact_id = r.contact_id)
                           when r.process_step_requirement_type_id = 12 and r.data_view_child_field_config_id is not null then
                             ( select flow.get_value_for_data_view_child_field(r.data_view_child_field_config_id, r.project_id)::text)
                           when r.process_step_requirement_type_id = 12 and r.data_view_field_config_id is not null then
                             ( select flow.get_value_for_data_view_field(r.data_view_field_config_id, r.project_id)::text) end
                 end as "textValue",
               case when r.data_type_id = 1 then
                      case when r.process_step_requirement_type_id = 1 then
                             case when r.main_project_process_step_id is not null then
                                    (select ppscfv1.date_value from flow.project_process_step_custom_field_value ppscfv1 where ppscfv1.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ppscfv1.project_process_step_id = r.main_project_process_step_id)
                                  else (select ppscfv.date_value from flow.project_process_step_custom_field_value ppscfv where ppscfv.project_process_step_id = r.project_process_step_id and ppscfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id) end
                           when r.process_step_requirement_type_id = 3 then
                             (select pcfv.date_value from flow.project_custom_field_value pcfv where pcfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and pcfv.project_id = r.project_id)
                           when r.process_step_requirement_type_id = 4 then
                             (select ccfv.date_value from flow.contact_custom_field_value ccfv where ccfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ccfv.contact_id = r.contact_id)
                           when r.process_step_requirement_type_id = 12 and r.data_view_child_field_config_id is not null then
                             ( select flow.get_value_for_data_view_child_field(r.data_view_child_field_config_id, r.project_id)::date)
                           when r.process_step_requirement_type_id = 12 and r.data_view_field_config_id is not null then
                             ( select flow.get_value_for_data_view_field(r.data_view_field_config_id, r.project_id)::date) end
                 end as "dateValue",
               case when r.data_type_id = 2 then
                      case when r.process_step_requirement_type_id = 1 then
                             case when r.main_project_process_step_id is not null then
                                    (select ppscfv1.timestamp_value from flow.project_process_step_custom_field_value ppscfv1 where ppscfv1.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ppscfv1.project_process_step_id = r.main_project_process_step_id)
                                  else (select ppscfv.timestamp_value from flow.project_process_step_custom_field_value ppscfv where ppscfv.project_process_step_id = r.project_process_step_id and ppscfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id) end
                           when r.process_step_requirement_type_id = 3 then
                             (select pcfv.timestamp_value from flow.project_custom_field_value pcfv where pcfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and pcfv.project_id = r.project_id)
                           when r.process_step_requirement_type_id = 4 then
                             (select ccfv.timestamp_value from flow.contact_custom_field_value ccfv where ccfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ccfv.contact_id = r.contact_id)
                           when r.process_step_requirement_type_id = 12 and r.data_view_child_field_config_id is not null then
                             ( select flow.get_value_for_data_view_child_field(r.data_view_child_field_config_id, r.project_id)::timestamp)
                           when r.process_step_requirement_type_id = 12 and r.data_view_field_config_id is not null then
                             ( select flow.get_value_for_data_view_field(r.data_view_field_config_id, r.project_id)::timestamp) end
                 end as "timestampValue",
               case when r.data_type_id = 3 then
                      case when r.process_step_requirement_type_id = 1 then
                             case when r.main_project_process_step_id is not null then
                                    (select ppscfv1.boolean_value from flow.project_process_step_custom_field_value ppscfv1 where ppscfv1.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ppscfv1.project_process_step_id = r.main_project_process_step_id)
                                  else (select ppscfv.boolean_value from flow.project_process_step_custom_field_value ppscfv where ppscfv.project_process_step_id = r.project_process_step_id and ppscfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id) end
                           when r.process_step_requirement_type_id = 3 then
                             (select pcfv.boolean_value from flow.project_custom_field_value pcfv where pcfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and pcfv.project_id = r.project_id)
                           when r.process_step_requirement_type_id = 4 then
                             (select ccfv.boolean_value from flow.contact_custom_field_value ccfv where ccfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ccfv.contact_id = r.contact_id)
                           when r.process_step_requirement_type_id = 12 and r.data_view_child_field_config_id is not null then
                             ( select flow.get_value_for_data_view_child_field(r.data_view_child_field_config_id, r.project_id)::boolean)
                           when r.process_step_requirement_type_id = 12 and r.data_view_field_config_id is not null then
                             ( select flow.get_value_for_data_view_field(r.data_view_field_config_id, r.project_id)::boolean) end
                 end as "booleanValue",
               case when r.data_type_id = 4 then
                      case when r.process_step_requirement_type_id = 1 then
                             case when r.main_project_process_step_id is not null then
                                    (select ppscfv1.numeric_value from flow.project_process_step_custom_field_value ppscfv1 where ppscfv1.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ppscfv1.project_process_step_id = r.main_project_process_step_id)
                                  else (select ppscfv.numeric_value from flow.project_process_step_custom_field_value ppscfv where ppscfv.project_process_step_id = r.project_process_step_id and ppscfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id) end
                           when r.process_step_requirement_type_id = 3 then
                             (select pcfv.numeric_value from flow.project_custom_field_value pcfv where pcfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and pcfv.project_id = r.project_id)
                           when r.process_step_requirement_type_id = 4 then
                             (select ccfv.numeric_value from flow.contact_custom_field_value ccfv where ccfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ccfv.contact_id = r.contact_id)
                           when r.process_step_requirement_type_id = 12 and r.data_view_child_field_config_id is not null then
                             ( select flow.get_value_for_data_view_child_field(r.data_view_child_field_config_id, r.project_id)::numeric)
                           when r.process_step_requirement_type_id = 12 and r.data_view_field_config_id is not null then
                             ( select flow.get_value_for_data_view_field(r.data_view_field_config_id, r.project_id)::numeric) end
                 end as "numericValue",
               case when r.data_type_id = 6 or r.data_type_id = 9 or r.data_type_id = 8 then
                      case when r.process_step_requirement_type_id = 1 then
                             case when r.main_project_process_step_id is not null then
                                    (select ppscfv1.int_value::bigint from flow.project_process_step_custom_field_value ppscfv1 where ppscfv1.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ppscfv1.project_process_step_id = r.main_project_process_step_id)
                                  else (select ppscfv.int_value::bigint from flow.project_process_step_custom_field_value ppscfv where ppscfv.project_process_step_id = r.project_process_step_id and ppscfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id) end
                           when r.process_step_requirement_type_id = 3 then
                             (select pcfv.int_value::bigint from flow.project_custom_field_value pcfv where pcfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and pcfv.project_id = r.project_id)
                           when r.process_step_requirement_type_id = 4 then
                             (select ccfv.int_value::bigint from flow.contact_custom_field_value ccfv where ccfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ccfv.contact_id = r.contact_id)
                           when r.process_step_requirement_type_id = 12 and r.data_view_child_field_config_id is not null then
                             ( select flow.get_value_for_data_view_child_field(r.data_view_child_field_config_id, r.project_id)::int)
                           when r.process_step_requirement_type_id = 12 and r.data_view_field_config_id is not null then
                             ( select flow.get_value_for_data_view_field(r.data_view_field_config_id, r.project_id)::int) end
                 end as "intValue",
               case when r.data_type_id = 7 or r.data_type_id = 10 then
                      case when r.process_step_requirement_type_id = 1 then
                             case when r.main_project_process_step_id is not null then
                                    coalesce(array_to_json(((select ppscfv1.int_array_value from flow.project_process_step_custom_field_value ppscfv1 where ppscfv1.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ppscfv1.project_process_step_id = r.main_project_process_step_id))), '[]')
                                  else coalesce(array_to_json(((select ppscfv.int_array_value from flow.project_process_step_custom_field_value ppscfv where ppscfv.project_process_step_id = r.project_process_step_id and ppscfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id))), '[]') end
                           when r.process_step_requirement_type_id = 3 then
                             coalesce(array_to_json(((select pcfv.int_array_value from flow.project_custom_field_value pcfv where pcfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and pcfv.project_id = r.project_id))), '[]')
                           when r.process_step_requirement_type_id = 4 then
                             coalesce(array_to_json(((select ccfv.int_array_value from flow.contact_custom_field_value ccfv where ccfv.custom_field_group_assignment_id = r.custom_field_group_assignment_id and ccfv.contact_id = r.contact_id))), '[]') end
                 end as "intArrayValue"
    from reqs r
    order by r.requirement_nbr;

END;
$BODY$
LANGUAGE plpgsql
VOLATILE
COST 100
ROWS 1000;
