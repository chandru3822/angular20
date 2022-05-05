CREATE OR REPLACE FUNCTION flow.get_data_view_field_configs(p_data_view_id integer,
                                                           p_object_code varchar,
                                                           p_cfga_id integer)
  RETURNS TABLE
          (
            dvfc_id                    integer,
            field_to_update            varchar,
            update_first_value_only    boolean,
            update_first_value_only_id varchar,
            column_name                varchar,
            contains_children          boolean,
            data_type_id               integer,
            process_step_event_id      integer,
            process_step_id            integer
          )
AS
$BODY$
BEGIN
  if p_cfga_id is not null then
    return query
      select dvfc.id as dvfc_id,
             dvfc.field_to_update,
             dvfc.update_first_value_only,
             dvfc.update_first_value_only_id,
             null::varchar,
             exists(select id
                    from flow.data_view_child_field_config dvcvc2
                    where dvcvc2.data_view_field_config_id = dvfc.id) as contains_children,
             dt.id                                as data_type_id,
             dvfc.process_step_event_id,
             dvfc.process_step_id
      from flow.data_view_field_config dvfc
             inner join flow.custom_field_group_assignment cfga
                        on dvfc.custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field cf on cfga.custom_field_id = cf.id
             inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
             inner join flow.data_type dt on cdt.data_type_id = dt.id
      where cfga.id = p_cfga_id and dvfc.data_view_id = p_data_view_id;
  else
  return query
    select dvfc.id                                                  as dvfc_id,
           dvfc.field_to_update,
           dvfc.update_first_value_only,
           dvfc.update_first_value_only_id,
           df.column_name,
           exists(select id
                  from flow.data_view_child_field_config dvcvc2
                  where dvcvc2.data_view_field_config_id = dvfc.id) as contains_children,
           dt.id                                                    as data_type_id,
           dvfc.process_step_event_id,
           dvfc.process_step_id
    from flow.data_view_field_config dvfc
           inner join flow.default_field df
                      on dvfc.default_field_id = df.id and df.watched_by_trigger is true
           inner join flow.data_type dt on df.data_type_id = dt.id
           inner join flow.object_type ot on df.object_type_id = ot.id and ot.object_code = p_object_code
    where dvfc.data_view_id = p_data_view_id;
    end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;

