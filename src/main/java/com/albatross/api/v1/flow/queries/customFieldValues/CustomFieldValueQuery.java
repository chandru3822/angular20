package com.albatross.api.v1.flow.queries.customFieldValues;

public class CustomFieldValueQuery {

  //language=PostgreSQL
  public final static String getListOfValueIdByCfgaIdAndName = """
    select lov.id
      from flow.list_of_value lov
      inner join flow.custom_field cf on cf.list_of_value_id = lov.parent_id
      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
      where cfga.id = :cfgaId and
            lov.parent_id is not null and
            lov.archived is not true and
            lower(lov.name) = lower(:name)
        """;

  //language=PostgreSQL
  public final static String upsertAuroraDesign = """
    insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, created_by_id, date_modified, json_value)
      select :sourceId, (
        select cfga.id
        from flow.custom_field_group_assignment cfga
               inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and (cfg.process_step_id = (select process_step_id from flow.project_process_step where id = :sourceId))
        where cfga.id = :customFieldGroupAssignmentId
          and cfga.archived is not true
      ), :userId, now(), :jsonValue::jsonb
      on conflict (project_process_step_id, custom_field_group_assignment_id)
        do update
        set json_value = :jsonValue::jsonb,
            modified_by_id = :userId,
            date_modified = now()
        """;


  //language=PostgreSQL
  public final static String updateValueUsingFunction = """
    select from flow.set_pps_cfv(:projectId::bigint, :userId::bigint, :cfgaId::bigint, :value::text, true)
    """;
}
