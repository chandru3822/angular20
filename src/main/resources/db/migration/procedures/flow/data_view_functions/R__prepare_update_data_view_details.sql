CREATE OR REPLACE FUNCTION flow.prepare_update_data_view_details(p_id integer,
                                                                 p_sql text,
                                                                 p_field_to_update character varying,
                                                                 p_value text,
                                                                 p_secondary_field_to_update text,
                                                                 p_secondary_value text,
                                                                 p_update_first_value_only boolean,
                                                                 p_update_first_value_only_id character varying,
                                                                 p_convert_date boolean default false,
                                                                 p_last_row boolean default false,
                                                                 p_add_where_clause boolean default false,
                                                                 p_where_clause_condition_ids text default null)
  RETURNS text AS

$BODY$
DECLARE
  v_now   text;
  v_value text;
BEGIN
  select flow.get_prepared_value(2, now()::text)
  into v_now;
  if p_add_where_clause is false then
    if p_secondary_field_to_update is not null then
      if p_convert_date is true then
        case
          when p_value is null then select 'null' into v_value;
          else select quote_literal(p_value) into v_value; end case;
        p_secondary_value = '(' || v_value || '::timestamp at time zone ' || quote_literal('UTC') ||
                            ' at time zone ' || quote_literal('US/Mountain') || ')::date';
      end if;
      p_sql = p_sql || p_secondary_field_to_update || $$ = $$ || p_secondary_value || $$ ,$$;
      return p_sql;
    end if;
    p_sql = p_sql || p_field_to_update || $$ = $$ || p_value || $$ ,$$;
    if p_last_row is true then
      p_sql = p_sql || $$ date_modified = $$ || v_now;
    end if;
    return p_sql;
  else
    if p_update_first_value_only is true then
      p_sql = p_sql || $$ where project_id = any( $$ || p_where_clause_condition_ids::text || $$)
     and ( $$ || p_field_to_update || $$ is null or ( $$ || p_update_first_value_only_id || $$ is not null and  $$ ||
              p_update_first_value_only_id || $$ = $$ || p_id || $$));$$;
    else
      p_sql = p_sql || $$ where project_id = any( $$ || p_where_clause_condition_ids::text || $$);$$;
    end if;
    --raise notice 'This is the p_sql %',p_sql;
    return p_sql;
  end if;
END ;
$BODY$
  LANGUAGE plpgsql volatile;



