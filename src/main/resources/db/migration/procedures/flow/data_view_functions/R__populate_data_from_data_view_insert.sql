CREATE OR REPLACE FUNCTION flow.populate_data_from_data_view_insert()
  RETURNS void
AS
$BODY$
declare
  z                                  record;
  x                                  record;
  v_schema_name                      varchar;
  v_view_name                        varchar;
  v_default_field_id                 integer;
  v_custom_field_group_assignment_id integer;
  v_process_step_event_id            integer;
  v_field_to_update                  varchar;
  v_update_first_value_only          boolean;
  v_update_first_value_only_id       varchar;
  v_sql                              text;
  v_object_type                      varchar;
  v_data_type_id                     integer;
  v_column_name                      varchar;
  v_text_array                       character varying[];
  v_second_value                     character varying;
BEGIN
  raise notice 'hi';
  for z in
    select *
    from flow.data_view_field_config_data
    where processed is false
    loop
      v_sql = $$with update_data as (
        select p.id,$$;
      select c.schema_name,
             dv.view_name,
             dvfc.default_field_id,
             dvfc.custom_field_group_assignment_id,
             dvfc.process_step_event_id,
             dvfc.field_to_update,
             dvfc.update_first_value_only,
             dvfc.update_first_value_only_id
      into v_schema_name,
        v_view_name,
        v_default_field_id,
        v_custom_field_group_assignment_id,
        v_process_step_event_id,
        v_field_to_update,
        v_update_first_value_only,
        v_update_first_value_only_id
      from flow.data_view_field_config dvfc
             inner join flow.data_view dv on dvfc.data_view_id = dv.id
             inner join flow.company c on dv.company_id = c.id
      where dvfc.id = z.data_view_field_config_id;

      if v_default_field_id is not null and v_process_step_event_id is null then

        select lower(ot.object_type), df.data_type_id, df.column_name
        into v_object_type,v_data_type_id,v_column_name
        from flow.default_field df
               inner join flow.object_type ot on df.object_type_id = ot.id
        where df.id = v_default_field_id;
        v_sql = v_sql || v_column_name || $$,$$;


        for x in select dvcfc.field_to_update,
                        quote_literal(ubt.unique_behavior_type) as unique_behavior_type,
                        dvcfc.data_type_id,
                        dt.data_type
                 from flow.data_view_child_field_config dvcfc
                        inner join flow.unique_behavior_type ubt on dvcfc.unique_behavior_type_id = ubt.id
                        inner join flow.data_type dt on dvcfc.data_type_id = dt.id
                 where dvcfc.data_view_field_config_id = z.data_view_field_config_id
          loop
            v_text_array = array_append(v_text_array, x.field_to_update);

            v_sql = v_sql || $$ flow.get_prepared_value($$ || x.data_type_id || $$,
                               flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,
                                                              $$ || v_column_name || $$, o.id))::$$ || x.data_type ||
                    $$ as $$ || x.field_to_update || $$,$$;
          end loop;
        raise notice 'array = %',v_text_array;
        v_sql = trim(trailing ' ,' from v_sql);
        v_sql = v_sql || $$ from flow.$$ || v_object_type || $$ o
                            inner join flow.project p on p.contact_id = o.id
                            where $$ || v_column_name || $$ is not null ) $$;
      end if;
      v_sql = v_sql || $$ update $$ || v_schema_name || $$.$$ || v_view_name || $$ foo set $$ || v_field_to_update ||
              $$ = ud.$$ || v_column_name;
      if array_length(v_text_array, 1) > 0 then
        FOREACH v_second_value IN ARRAY v_text_array
          LOOP
            v_sql = v_sql || $$ , $$ || v_second_value || $$ = ud.$$ || v_second_value;
          END LOOP;
      end if;

      v_sql = v_sql || $$ from update_data ud where ud.id = foo.id;$$;
      raise notice 'v_sql = %',v_sql;
    end loop;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;



--TODO  one update statement per view for all object types
