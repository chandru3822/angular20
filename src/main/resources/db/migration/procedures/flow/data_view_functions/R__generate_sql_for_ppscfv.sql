CREATE OR REPLACE procedure flow.generate_sql_for_ppscfv(in z record,
                                                         in p_in_ppscfv integer,
                                                         inout p_sql text ,
                                                         inout p_text_array_tables character varying[],
                                                         inout p_text_array_alias_columns character varying[],
                                                         inout p_text_array_columns       character varying[])
AS
$BODY$
declare
  x record;
  v_value character varying;
  v_order text;
BEGIN

      if p_in_ppscfv > 1 then
        p_sql = p_sql || $$ pp_step_$$||p_in_ppscfv||$$ as (select distinct on (pps.project_id) pps.project_id as id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ($$pp_step_$$||p_in_ppscfv|| $$ ps_$$||p_in_ppscfv)::character varying);
      elsif z.object_type = 'process_step' and (p_sql = '') IS NOT FALSE then
        p_sql = $$with pp_step as (select distinct on (pps.project_id) pps.project_id as id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ('pp_step ps')::character varying);
      elsif z.object_type = 'process_step' and (p_sql = '') IS FALSE and
            position('pp_step' in p_sql) < 1 then
        p_sql = p_sql || $$ pp_step as (select distinct on (pps.project_id) pps.project_id as id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ('pp_step ps')::character varying);
      end if;
      v_value = $$ps.$$;
      if p_in_ppscfv > 1 then
        v_value = $$ps_$$||p_in_ppscfv||$$.$$;
      end if;
      p_sql = p_sql ||$$ppscfv.$$|| case
                         when z.data_type_id = 1 then 'date_value'
                         when z.data_type_id = 2 then 'timestamp_value'
                         when z.data_type_id = 3 then 'boolean_value'
                         when z.data_type_id = 4 then 'numeric_value'
                         when z.data_type_id = 5 then 'text_value'
                         when z.data_type_id = 6 then 'int_value'
                         when z.data_type_id = 7 then 'int_array_value'
                         when z.data_type_id in (8, 9) then 'int_value' end || $$ as $$ || z.field_to_update || $$,$$;

      p_text_array_alias_columns =
        array_append(p_text_array_alias_columns, (v_value || z.field_to_update)::character varying);
      p_text_array_columns  = array_append(p_text_array_columns , z.field_to_update);
      v_order = $$desc$$;
      if z.update_first_value_only is true then
        v_order = $$asc$$;
        p_sql = p_sql || $$ppscfv.id as $$|| z.update_first_value_only_id||$$,$$;
        p_text_array_alias_columns =
          array_append(p_text_array_alias_columns, (v_value || z.update_first_value_only_id)::character varying);
        p_text_array_columns  = array_append(p_text_array_columns , z.update_first_value_only_id);
      end if;
      for x in select dvcfc.field_to_update,
                      quote_literal(ubt.unique_behavior_type) as unique_behavior_type,
                      dvcfc.data_type_id,
                      dt.data_type
               from flow.data_view_child_field_config dvcfc
                      inner join flow.unique_behavior_type ubt on dvcfc.unique_behavior_type_id = ubt.id
                      inner join flow.data_type dt on dvcfc.data_type_id = dt.id
               where dvcfc.data_view_field_config_id = z.data_view_field_config_id
        loop
          p_text_array_columns  = array_append(p_text_array_columns , x.field_to_update);
          p_text_array_alias_columns =
            array_append(p_text_array_alias_columns, (v_value || x.field_to_update)::character varying);
          p_sql = p_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,$$ || case when z.data_type_id = 1 then 'date_value'
                                                                         when z.data_type_id = 2 then 'timestamp_value'
                                                                         when z.data_type_id = 3 then 'boolean_value'
                                                                         when z.data_type_id = 4 then 'numeric_value'
                                                                         when z.data_type_id = 5 then 'text_value'
                                                                         when z.data_type_id = 6 then 'int_value'
                                                                         when z.data_type_id = 7 then 'int_array_value'
                                                                         when z.data_type_id in (8, 9) then 'int_value' end ||
                                                                          $$, ppscfv.id)::$$ || x.data_type ||
                                                                          $$ as $$ || x.field_to_update || $$,$$;
        end loop;

        p_sql = trim(trailing ' ,' from p_sql);
        p_sql = p_sql || $$ from flow.project_process_step pps
                        inner join flow.project_process_step_custom_field_value ppscfv on pps.id = ppscfv.project_process_step_id
                          and ppscfv.custom_field_group_assignment_id =  $$ || z.custom_field_group_assignment_id || $$
                          inner join flow.project p on p.id = pps.project_id
                          where p.company_process_id = any('$$||z.company_process_ids::text||$$'::integer[])
                          order by pps.id $$||v_order||$$ ), $$;

END
$BODY$
  LANGUAGE plpgsql;

