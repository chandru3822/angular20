package com.albatross.api.v1.flow.queries;

public class CompanyFunctionQuery {

  //language=PostgreSQL
  public final static String getFunctions = """
     select cf.*,
           df.return_data_type_id
      from flow.company_function cf
        inner join flow.db_function df on df.id = cf.db_function_id
      where cf.company_id = :companyId
        and cf.archived is not true
        and df.archived is not true
      order by cf.company_function_name
    """;

  //language=PostgreSQL
  public final static String getFunctionsByType = """
     select cf.*,
           df.return_data_type_id,
            df.db_function_type_id
      from flow.company_function cf
        inner join flow.db_function df on df.id = cf.db_function_id
      where cf.company_id = :companyId
        and cf.archived is not true
        and df.archived is not true
        and df.db_function_type_id = :typeId
        and case when :eventActionable::boolean then df.event_actionable = :eventActionable
             when :processStepActionable::boolean then df.process_step_actionable = :processStepActionable else true end
      order by cf.company_function_name
    """;

  //language=PostgreSQL
  public final static String deleteCompanyFunction = """
    update flow.company_function
      set archived = true
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getFunctionDetails = """
 select cf.*,
           df.description,
           coalesce((
                SELECT array_to_json(array_agg(row_to_json(params)))
                FROM (
                         select cfp.id,
                                case when cfp.company_function_id is null then cf.id else cfp.company_function_id end as "companyFunctionId",
                                cfp.archived,
                                cfp.custom_field_group_assignment_id as "customFieldGroupAssignmentId",
                                cf2.field_name as "fieldName",
                                ps.id as "processStepId",
                                ps.process_step_name as "processStepName",
                                dfp.system_value_id as "systemValueId",
                                sv.system_value as "systemValue",
                                dfp.id as "dbFunctionParamId",
                                dfp.db_function_id as "dbFunctionId",
                                dfp.parameter_name as "parameterName",
                                dfp.display_order as "displayOrder",
                                dfp.data_type_id as "dataTypeId",
                                dfp.parameter_type_id as "parameterTypeId"
                         from flow.db_function_param dfp
                          left join flow.company_function_param cfp on cfp.db_function_param_id = dfp.id and cfp.archived is not true and cfp.company_function_id = cf.id
                          left join flow.system_value sv on sv.id = dfp.system_value_id
                          left join flow.custom_field_group_assignment cfga on cfga.id = cfp.custom_field_group_assignment_id
                          left join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                          left join flow.process_step ps on ps.id = cfg.process_step_id
                          left join flow.custom_field cf2 on cf2.id = cfga.custom_field_id
                         where dfp.db_function_id = df.id
                            and dfp.archived is not true
                         order by dfp.display_order) params), '[]') AS "companyFunctionParams"
    from flow.company_function cf
             inner join flow.db_function df on df.id = cf.db_function_id
    where cf.id = :id
    """;

  //language=PostgreSQL
  public final static String getCompanyParam = """
    select cfp.*,
           sv.system_value,
           cf.field_name,
           ps.id as "processStepId",
           ps.process_step_name as "processStepName"
    from flow.company_function_param cfp
        inner join flow.db_function_param dfp on dfp.id = cfp.db_function_param_id
        left join flow.system_value sv on sv.id = dfp.system_value_id
        left join flow.custom_field_group_assignment cfga on cfga.id = cfp.custom_field_group_assignment_id
        left join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
        left join flow.process_step ps on ps.id = cfg.process_step_id
        left join flow.custom_field cf on cf.id = cfga.custom_field_id
    where cfp.id = :id
    """;

  //language=PostgreSQL
  public final static String getFunctionDynamicParams = """
    select dfp.id db_function_param_id,
           dfp.data_type_id,
           dfp.parameter_name,
           dfp.description,
           case when dfp.data_type_id = 3 then false end as dynamic_value
    from flow.db_function_param dfp
    where dfp.db_function_id = :dbFunctionId
      and dfp.archived is not true
      and dfp.parameter_type_id = :parameterTypeId
    order by dfp.display_order
    """;

  //language=PostgreSQL
  public final static String updateCompanyFunctionParam = """
    update flow.company_function_param
    set custom_field_group_assignment_id = :customFieldGroupAssignmentId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertCompanyFunctionParam = """
    insert into flow.company_function_param (company_function_id, custom_field_group_assignment_id, db_function_param_id) values
      (:companyFunctionId, :customFieldGroupAssignmentId, :dbFunctionParamId)
    """;

}
