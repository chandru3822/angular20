CREATE OR REPLACE procedure flow.generate_sql_for_pcfv(in z record,
                                                         in p_in_pcfv integer,
                                                         inout p_sql text ,
                                                         inout p_text_array_tables character varying[],
                                                         inout p_text_array_alias_columns character varying[],
                                                         inout p_text_array_columns       character varying[])
AS
$BODY$
declare
  x record;
  v_value character varying;
BEGIN
      if p_in_pcfv > 1 then
        p_sql = p_sql || $$ project_details_$$||p_in_pcfv||$$ as (select p.id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ($$project_details_$$||p_in_pcfv|| $$ pd_$$||p_in_pcfv)::character varying);
      elsif z.object_type = 'project' and z.custom_field_group_assignment_id is not null and (p_sql = '') IS NOT FALSE then
        p_sql = $$with project_details as (select p.id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ('project_details pd')::character varying);
      elsif z.object_type = 'project' and z.custom_field_group_assignment_id is not null and (p_sql = '') IS FALSE and
            position('project_details' in p_sql) < 1 then
        p_sql = p_sql || $$ project_details as (select p.id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ('project_details pd')::character varying);
      end if;

        v_value = $$pd.$$;
        if p_in_pcfv > 1 then
          v_value = $$pd_$$||p_in_pcfv||$$.$$;
        end if;

      p_sql = p_sql ||$$pcfv.$$|| flow.get_value_based_on_data_type(z.data_type_id) || $$ as $$ || z.field_to_update || $$,$$;


      p_text_array_alias_columns =
        array_append(p_text_array_alias_columns, (v_value || z.field_to_update)::character varying);
      p_text_array_columns  = array_append(p_text_array_columns , z.field_to_update);
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
          p_sql = p_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,$$
                    || flow.get_value_based_on_data_type(z.data_type_id) || $$, pcfv.id,$$|| quote_literal('PROJECT')||$$)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;

    p_sql = trim(trailing ' ,' from p_sql);
    p_sql = p_sql || $$ from flow.project p
                      inner join flow.project_custom_field_value pcfv on p.id = pcfv.project_id
                        and pcfv.custom_field_group_assignment_id = $$ || z.custom_field_group_assignment_id || $$
                        where p.company_process_id = any('$$||z.company_process_ids::text||$$'::integer[])), $$;


END
$BODY$
  LANGUAGE plpgsql;

