drop procedure if exists flow.generate_sql_for_ppscfv(in z record,
                                                      in p_in_ppscfv bigint,
                                                      inout p_sql text,
                                                      inout p_text_array_tables character varying[],
                                                      inout p_text_array_alias_columns character varying[],
                                                      inout p_text_array_columns character varying[]);
CREATE OR REPLACE procedure flow.generate_sql_for_ppscfv(in z record,
                                                         in p_in_ppscfv bigint,
                                                         inout p_sql text,
                                                         inout p_text_array_tables character varying[],
                                                         inout p_text_array_alias_columns character varying[],
                                                         inout p_text_array_columns character varying[])
AS
$BODY$
declare
  x                               record;
  v_value                         character varying;
  v_order                         text;
  v_join                          text;
  v_field_required                boolean default false;
  v_additional_where_clause       text;
  v_another_where_clause          text;
  v_add_another_where_clause      boolean;
BEGIN



  if p_in_ppscfv > 1 then
    p_sql = p_sql || $$ pp_step_$$ || p_in_ppscfv || $$ as (select distinct on (pps.project_id) pps.project_id as id,$$;
    p_text_array_tables =
      array_append(p_text_array_tables, ($$pp_step_$$ || p_in_ppscfv || $$ ps_$$ || p_in_ppscfv)::character varying);
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
    v_value = $$ps_$$ || p_in_ppscfv || $$.$$;
  end if;
  p_sql = p_sql || $$ppscfv.$$ || flow.get_value_based_on_data_type(z.data_type_id) || $$ as $$ || z.field_to_update ||
          $$,$$;

  p_text_array_alias_columns =
    array_append(p_text_array_alias_columns, (v_value || z.field_to_update)::character varying);
  p_text_array_columns = array_append(p_text_array_columns, z.field_to_update);
  v_order = $$ppscfv.date_modified desc$$;
  if z.update_first_value_only is true then
    v_order = $$pps.date_created asc$$;
    p_sql = p_sql || $$ppscfv.id as $$ || z.update_first_value_only_id || $$,$$;
    p_text_array_alias_columns =
      array_append(p_text_array_alias_columns, (v_value || z.update_first_value_only_id)::character varying);
    p_text_array_columns = array_append(p_text_array_columns, z.update_first_value_only_id);
    v_additional_where_clause = $$ and exists (select id from $$ || z.schema_name || $$.$$ || z.view_name || $$
                                        where $$ || z.update_first_value_only_id || $$is null)$$;
  end if;

  for x in select dvcfc.field_to_update,
                  quote_literal(ubt.unique_behavior_code) as unique_behavior_code,
                  ubt.return_data_type_id                 as data_type_id,
                  dt.data_type
           from flow.data_view_child_field_config dvcfc
                  inner join flow.unique_behavior_type ubt on dvcfc.unique_behavior_type_id = ubt.id
                  inner join flow.data_type dt on ubt.return_data_type_id = dt.id
           where dvcfc.data_view_field_config_id = z.data_view_field_config_id
    loop
      p_text_array_columns = array_append(p_text_array_columns, x.field_to_update);
      p_text_array_alias_columns =
        array_append(p_text_array_alias_columns, (v_value || x.field_to_update)::character varying);
      p_sql = p_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_code || $$, ppscfv.$$ ||
              flow.get_value_based_on_data_type(z.data_type_id) ||
              $$::text,0::bigint, ppscfv.id,$$ || quote_literal('PROCESS_STEP') || $$)::$$ || x.data_type ||
              $$ as $$ || x.field_to_update || $$,$$;
    end loop;

  v_join = $$ inner $$;
  if z.reset_values_on_main is true then
    v_join = $$ left $$;
  end if;
  v_field_required = false;
  if (z.reset_values_on_main is false and z.update_first_value_only is false) or
     (z.reset_values_on_main is false and z.update_first_value_only is true) then
    v_field_required = true;
  end if;
  v_add_another_where_clause = false;
  if z.reset_values_on_main is true and z.ignore_if_null is false then
    v_add_another_where_clause = true;
    v_another_where_clause = $$ pps.main is true $$;
    v_field_required = false;
  elsif z.reset_values_on_main is true and z.ignore_if_null is true then
    v_add_another_where_clause = true;
    v_another_where_clause =
      $$ and ((pps.main is true and pps.$$ || z.column_name || $$ is not null) or (pps.main is false)) $$;
    v_field_required = false;
  elsif z.reset_values_on_main is false and z.ignore_if_null is false then
    v_field_required = true;
  end if;

  p_sql = trim(trailing ' ,' from p_sql);
  p_sql = p_sql || $$ from flow.project_process_step pps
                          $$ || v_join || $$ join flow.project_process_step_custom_field_value ppscfv on pps.id = ppscfv.project_process_step_id
                          and ppscfv.custom_field_group_assignment_id =  $$ || z.custom_field_group_assignment_id || $$
                          inner join flow.project p on p.id = pps.project_id
                          inner join flow.process_step ps on ps.id = pps.process_step_id and ps.id = $$ ||
          z.process_step_id || $$
                          where case when $$ || v_field_required || $$ is true then ppscfv.$$ ||
          flow.get_value_based_on_data_type(z.data_type_id) ||
          $$ is not null else 1=1 end and
                                p.company_process_id = any('$$ || z.company_process_ids::text || $$'::bigint[]) $$;
  if z.update_first_value_only is true then
    p_sql = p_sql || v_additional_where_clause;
  end if;
  if v_add_another_where_clause is true then
    p_sql = p_sql || v_another_where_clause;
  end if;
  p_sql = p_sql || $$order by pps.project_id,$$ || v_order || $$ ), $$;

END
$BODY$
  LANGUAGE plpgsql;

