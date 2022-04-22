CREATE OR REPLACE function flow.initialize_data_view_table(p_company_id integer,p_table_name character varying)
  returns void
AS $BODY$
declare
  v_schema_name character varying;
BEGIN

  select schema_name
  into v_schema_name
  from flow.company
  where id = p_company_id;

  execute $$Create table if NOT EXISTS $$||v_schema_name||$$.$$||p_table_name||$$ (id serial not null primary key,
                                                                      project_id integer not null,
                                                                      contact_id integer,
                                                                      date_modified timestamp without time zone DEFAULT now() not null );$$;

  execute $$insert into $$||v_schema_name||$$.$$||p_table_name||$$(project_id, contact_id, date_modified)
(select p.id,p.contact_id,now()
 from flow.project p); $$;

END
$BODY$
  LANGUAGE plpgsql;
