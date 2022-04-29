CREATE OR REPLACE procedure flow.generate_sql_for_ccfv(in z record,
                                                         in p_in_ccfv integer,
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
      if p_in_ccfv > 1 then
        p_sql = p_sql || $$ contact_details_$$||p_in_ccfv||$$ as (select p.id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ($$contact_details_$$||p_in_ccfv|| $$ cd_$$||p_in_ccfv)::character varying);
      elsif z.object_type = 'contact' and z.custom_field_group_assignment_id is not null and (p_sql = '') IS NOT FALSE then
        p_sql = $$with contact_details as (select p.id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ('contact_details cd')::character varying);
      elsif z.object_type = 'contact' and z.custom_field_group_assignment_id is not null and (p_sql = '') IS FALSE and
            position('contact_details' in p_sql) < 1 then
        p_sql = p_sql || $$ contact_details as (select p.id,$$;
        p_text_array_tables = array_append(p_text_array_tables, ('contact_details cd')::character varying);
      end if;

        v_value = $$cd.$$;
        if p_in_ccfv > 1 then
          v_value = $$cd_$$||p_in_ccfv||$$.$$;
        end if;

      p_sql = p_sql ||$$ccfv.$$|| case
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
                    || case
                         when z.data_type_id = 1 then 'date_value'
                         when z.data_type_id = 2 then 'timestamp_value'
                         when z.data_type_id = 3 then 'boolean_value'
                         when z.data_type_id = 4 then 'numeric_value'
                         when z.data_type_id = 5 then 'text_value'
                         when z.data_type_id = 6 then 'int_value'
                         when z.data_type_id = 7 then 'int_array_value'
                         when z.data_type_id in (8, 9) then 'int_value' end || $$, ccfv.id)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;

    p_sql = trim(trailing ' ,' from p_sql);
    p_sql = p_sql || $$ from flow.project p
                      inner join flow.contact c on c.id = p.contact_id
                      inner join flow.contact_custom_field_value ccfv on c.id = ccfv.contact_id
                        and ccfv.custom_field_group_assignment_id = $$ || z.custom_field_group_assignment_id || $$
                        where p.company_process_id = any('$$||z.company_process_ids::text||$$'::integer[])), $$;


END
$BODY$
  LANGUAGE plpgsql;

