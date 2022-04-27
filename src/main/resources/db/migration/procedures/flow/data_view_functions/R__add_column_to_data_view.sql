CREATE OR REPLACE function flow.add_column_to_data_view(p_data_view_field_config_id integer,
                                                        p_data_view_child_field_config_id integer)
  returns void
AS
$BODY$
declare
  v_field_to_update            varchar;
  v_data_type                  varchar;
  v_update_first_value_only    boolean;
  v_data_type_id               integer;
  v_schema_name                varchar;
  v_view_name                  varchar;
  v_update_first_value_only_id varchar;
  v_data_view_field_config_id  integer;
BEGIN

  if p_data_view_field_config_id is not null and p_data_view_child_field_config_id is null then
    select dvfc.id,
           dvfc.field_to_update,
           coalesce(dt.data_type, dt2.data_type) as data_type,
           dvfc.update_first_value_only,
           coalesce(dt.id, dt2.id)               as data_type_id,
           c.schema_name,
           dv.view_name,
           dvfc.update_first_value_only_id
    into v_data_view_field_config_id,v_field_to_update,v_data_type,v_update_first_value_only,v_data_type_id,
      v_schema_name,v_view_name,v_update_first_value_only_id
    from flow.data_view_field_config dvfc
           inner join flow.data_view dv on dvfc.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           left join flow.custom_field_group_assignment cfga on dvfc.custom_field_group_assignment_id = cfga.id
           left join flow.custom_field cf on cfga.custom_field_id = cf.id
           left join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
           left join flow.data_type dt2 on cdt.data_type_id = dt2.id
           left join flow.default_field df on dvfc.default_field_id = df.id
           left join flow.data_type dt on df.data_type_id = dt.id
    where dvfc.id = p_data_view_field_config_id;

    if v_data_type_id = 7 then
      v_data_type = 'integer[]';
    elsif v_data_type_id in (8, 9) then
      v_data_type = 'integer';
    end if;
    --     v_sql = $$ALTER TABLE $$||v_schema_name||$$.$$||v_view_name||$$ ADD COLUMN if not exists $$ || v_field_to_update || $$ $$ ||v_data_type||$$;$$;
--     raise notice 'what is this %',v_sql;
    EXECUTE $$ALTER TABLE $$ || v_schema_name || $$.$$ || v_view_name || $$ ADD COLUMN if not exists $$ ||
            v_field_to_update || $$ $$ || v_data_type || $$;$$;
    EXECUTE $$CREATE INDEX  ON $$ || v_schema_name || $$.$$ || v_view_name || $$($$ || v_field_to_update || $$);$$;

    if v_update_first_value_only is true then
      v_data_type = 'integer';
      EXECUTE $$ALTER TABLE $$ || v_schema_name || $$.$$ || v_view_name || $$ ADD COLUMN if not exists $$ ||
              v_field_to_update || $$_cfv_id $$ || v_data_type || $$;$$;
      EXECUTE $$CREATE INDEX  ON $$ || v_schema_name || $$.$$ || v_view_name || $$($$ || v_field_to_update ||
              $$_cfv_id);$$;

    end if;
    insert into flow.data_view_field_config_data(data_view_field_config_id,date_created)
    values(p_data_view_field_config_id,now());
  else
    select dvcvw.field_to_update, dt2.data_type,
          c.schema_name,dv.view_name
    into v_field_to_update,v_data_type,
         v_schema_name,v_view_name
    from flow.data_view_child_field_config dvcvw
           inner join flow.data_type dt2 on dvcvw.data_type_id = dt2.id
           inner join flow.data_view_field_config dvfc2 on dvcvw.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on c.id = dv.company_id
    where dvcvw.id = p_data_view_child_field_config_id;

    EXECUTE $$ALTER TABLE $$ || v_schema_name || $$.$$ || v_view_name || $$ ADD COLUMN if not exists $$ ||
            v_field_to_update || $$ $$ || v_data_type || $$;$$;
    EXECUTE $$CREATE INDEX  ON $$ || v_schema_name || $$.$$ || v_view_name || $$($$ || v_field_to_update || $$);$$;
  end if;

END
$BODY$
  LANGUAGE plpgsql;
