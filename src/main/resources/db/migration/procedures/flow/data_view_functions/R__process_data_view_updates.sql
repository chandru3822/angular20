drop procedure if exists flow.process_data_view_updates();
CREATE OR REPLACE procedure flow.process_data_view_updates()
AS
$BODY$
declare
  x         record;
  y         record;
  v_records integer[];
  v_count   integer default 0;
  v_sql text;
BEGIN
  delete
  from flow.data_view_update dvu
  where generated_update is null;
  for y in  select dv.view_name,c.schema_name
            from flow.data_view dv
                   inner join flow.company c on c.id = dv.company_id
  loop
      v_sql = null;
      v_sql = $$ALTER TABLE $$ ||y.schema_name||$$.$$||y.view_name||$$
        SET (autovacuum_enabled = false);$$;
      execute v_sql;
  end loop;

  for x in select *
           from flow.data_view_update
    loop
      v_count = v_count + 1;
      v_records = array_append(v_records, x.id);
      execute x.generated_update;
      if v_count = 1000 then
        delete
        from flow.data_view_update
        where id = any (v_records);
        commit;
        v_count = 0;
        v_records = null;
      end if;
    end loop;

  delete from flow.data_view_update;

  ALTER SEQUENCE flow.data_view_update_id_seq RESTART WITH 1;

  for y in  select dv.view_name,c.schema_name
            from flow.data_view dv
                   inner join flow.company c on c.id = dv.company_id
    loop
      v_sql = null;
      v_sql = $$ALTER TABLE $$ ||y.schema_name||$$.$$||y.view_name||$$
        SET (autovacuum_enabled = true);$$;
      execute v_sql;
    end loop;

END
$BODY$
  LANGUAGE plpgsql;

