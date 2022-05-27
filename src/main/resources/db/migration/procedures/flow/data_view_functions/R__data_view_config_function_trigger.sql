CREATE OR REPLACE FUNCTION flow.contact_details()
  RETURNS TRIGGER AS
$body$
declare
  v_project_ids         text;
  x                     record;
  v_sql                 text;
  z                     record;
  v_value               text;
  v_company_process_ids integer[];
BEGIN
  select quote_literal(array_agg(id)::text), array_agg(distinct company_process_id)
  into v_project_ids,v_company_process_ids
  from flow.project
  where contact_id = new.id;

  if v_project_ids is not null then
    for z in select *
             from flow.get_schema_by_company(new.company_id) dv
             where exists(select ao.dvfc_id
                          from flow.get_data_view_field_configs(dv.id,
                                                                'CONTACT',
                                                                null) ao)
               and v_company_process_ids && dv.company_process_ids
      loop
        select quote_literal(array_agg(id)::text)
        into v_project_ids
        from flow.project
        where contact_id = new.id
          and company_process_id = any (z.company_process_ids);
        v_sql = NULL;
        v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
        for x in select a.*, lead(a.dvfc_id) OVER () IS NULL::boolean AS is_last_row
                 from flow.get_data_view_field_configs(z.id,
                                                       'CONTACT',
                                                       null) a
                 where exists(select dvfc2.id
                              from flow.data_view_field_config dvfc2
                              where dvfc2.data_view_id = z.id
                                and dvfc2.id = a.dvfc_id
                         )
          loop
            execute format('SELECT $1.%I', x.column_name)
              into v_value using new;
            select *
            into v_sql
            from flow.execute_data_view_field_configs(x.contains_children,
                                                      v_value,
                                                      x.dvfc_id,
                                                      new.id,
                                                      v_sql,
                                                      x.field_to_update,
                                                      x.update_first_value_only,
                                                      x.update_first_value_only_id,
                                                      x.is_last_row,
                                                      x.data_type_id);
          end loop;
        select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                     v_value, null::text, null::text,
                                                     x.update_first_value_only,
                                                     x.update_first_value_only_id,
                                                     false,
                                                     x.is_last_row, true, v_project_ids)
        into v_sql;
        begin
          execute v_sql;
        exception
          when others then
            insert into flow.trigger_error(contact_id, error)
            values (new.id, SQLERRM);
        end;
      end loop;

  end if;
  RETURN null;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists contact_details_trg on flow.contact;
CREATE TRIGGER contact_details_trg
  after update
  ON flow.contact
  FOR EACH ROW
  --  when (new.temp_geo_attempted is false)
EXECUTE PROCEDURE flow.contact_details();

CREATE OR REPLACE FUNCTION flow.update_contact_custom_field_value_details()
  RETURNS TRIGGER AS
$body$

declare
  z             record;
  x             record;
  v_project_ids text;
  v_company_id  integer;
  v_sql         character varying;
  v_value       character varying;
  v_count       bigint;
  v_company_process_ids integer[];
BEGIN
  select quote_literal(array_agg(p.id)::text),array_agg(distinct p.company_process_id)
  into v_project_ids,v_company_process_ids
  from flow.contact c
         inner join flow.project p on c.id = p.contact_id
  where c.id = new.contact_id;
  select company_id
  into v_company_id
  from flow.contact c
  where c.id = new.contact_id;

  for z in select *
           from flow.get_schema_by_company(v_company_id) dv
           where exists(select ao.dvfc_id
                        from flow.get_data_view_field_configs(dv.id,
                                                              null,
                                                              new.custom_field_group_assignment_id) ao) and
               v_company_process_ids && dv.company_process_ids
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select a.*,lead(a.dvfc_id) OVER () IS NULL::boolean AS is_last_row
               from flow.get_data_view_field_configs(z.id,
                                                     null,
                                                     new.custom_field_group_assignment_id) a
        loop
          select *
          into v_sql
          from flow.execute_data_view_field_configs(x.contains_children,
                                                    case
                                                      when x.data_type_id = 1 then new.date_value::text
                                                      when x.data_type_id = 2 then new.timestamp_value::text
                                                      when x.data_type_id = 3 then new.boolean_value::text
                                                      when x.data_type_id = 4 then new.numeric_value::text
                                                      when x.data_type_id in (5,13) then new.text_value::text
                                                      when x.data_type_id = 6 then new.int_value::text
                                                      when x.data_type_id = 7 then new.int_array_value::text
                                                      when x.data_type_id in (8, 9) then new.int_value::text end,
                                                    x.dvfc_id,
                                                    new.id,
                                                    v_sql,
                                                    x.field_to_update,
                                                    x.update_first_value_only,
                                                    x.update_first_value_only_id,
                                                    x.is_last_row,
                                                    x.data_type_id);


        end loop;
      select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                   v_value, null::text, null::text,
                                                   x.update_first_value_only,
                                                   x.update_first_value_only_id,
                                                   false,
                                                   x.is_last_row, true, v_project_ids)
      into v_sql;
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(contact_custom_field_value_id, error)
          values (new.id, SQLERRM);
      end;
    end loop;

--TODO what to do here
  if (TG_OP = 'UPDATE') THEN

    select count(1)
    into v_count
    from flow.user_position up
           inner join flow.white_listed_position wlp on wlp.position_id = up.position_id and wlp.archived is false
    where up.user_id = new.modified_by_id
      and up.end_date is null
      and wlp.custom_field_group_assignment_id = 395;
    if new.custom_field_group_assignment_id = 395 and old.int_value != new.int_value and v_count < 1 then
      raise exception 'You do not have rights to update the Lead Source for this Contact. (B)';
    end if;
  end if;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_contact_custom_field_value_trg on flow.contact_custom_field_value;
CREATE TRIGGER update_contact_custom_field_value_trg
  after INSERT or update
  ON flow.contact_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_contact_custom_field_value_details();


CREATE OR REPLACE FUNCTION flow.project_details()
  RETURNS TRIGGER AS
$body$
declare
  x             record;
  v_sql         text;
  v_insert_sql  text;
  z             record;
  v_company_id  integer;
  v_project_ids text;
  v_value       text;
  y             record;
BEGIN
  select company_id
  into v_company_id
  from flow.company_process cp
  where process_id = new.company_process_id
  limit 1;

  IF (TG_OP = 'INSERT') THEN
    for y in select dv2.view_name,c.schema_name
             from flow.data_view dv2
             inner join flow.company c on dv2.company_id = c.id
             where new.company_process_id = any (dv2.company_process_ids)
      loop
        v_insert_sql = $$insert into $$||y.schema_name||$$.$$||y.view_name||$$(project_id, company_id, contact_id,date_modified) values ($$
        ||new.id||$$,$$||v_company_id||$$,$$||new.contact_id||$$,$$||quote_literal(now())||$$);$$;
        execute v_insert_sql;
        update flow.contact set id = id where id = new.contact_id;
      end loop;

      update flow.contact
      set date_modified = now()
    where id = new.contact_id;
  end if;

  select quote_literal(array_agg(new.id)::text)
  into v_project_ids;

  for z in select *
           from flow.get_schema_by_company(v_company_id) dv
           where exists(select ao.dvfc_id
                        from flow.get_data_view_field_configs(dv.id,
                                                              'PROJECT',
                                                              null) ao) and
             new.company_process_id = any(dv.company_process_ids)

    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select a.*,lead(a.dvfc_id) OVER () IS NULL::boolean AS is_last_row
               from flow.get_data_view_field_configs(z.id,
                                                     'PROJECT',
                                                     null) a
               where exists(select dvfc2.id
                            from flow.data_view_field_config dvfc2
                            where dvfc2.data_view_id = z.id
                              and dvfc2.id = a.dvfc_id)
        loop
          execute format('SELECT $1.%I', x.column_name)
            into v_value using new;
          select *
          into v_sql
          from flow.execute_data_view_field_configs(x.contains_children,
                                                    v_value,
                                                    x.dvfc_id,
                                                    new.id,
                                                    v_sql,
                                                    x.field_to_update,
                                                    x.update_first_value_only,
                                                    x.update_first_value_only_id,
                                                    x.is_last_row,
                                                    x.data_type_id);

        end loop;
      select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                   v_value, null::text, null::text,
                                                   x.update_first_value_only,
                                                   x.update_first_value_only_id,
                                                   false,
                                                   x.is_last_row, true, v_project_ids)
      into v_sql;
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(project_id, error)
          values (new.id, SQLERRM);
      end;
    end loop;
  perform flow.company_project_specific_tasks(v_company_id, new.company_project_status_type_id,
                                              old.company_project_status_type_id,
                                              new.id);

  RETURN null;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists project_project_details_trg on flow.project;
CREATE TRIGGER project_project_details_trg
  after INSERT or delete or update
  ON flow.project
  FOR EACH ROW
EXECUTE PROCEDURE flow.project_details();


CREATE OR REPLACE FUNCTION flow.update_project_custom_field_value_details()
  RETURNS TRIGGER AS
$body$

declare
  v_project_ids text;
  z             record;
  x             record;
  v_company_id  integer;
  v_sql         character varying;
  v_value       character varying;
  v_count       integer;
  v_company_process_id integer;
BEGIN

  select company_id,p.company_process_id
  into v_company_id,v_company_process_id
  from flow.project p
         inner join flow.contact c on c.id = p.contact_id
  where p.id = new.project_id;

  select quote_literal(array_agg(new.project_id)::text)
  into v_project_ids;
  for z in select *
           from flow.get_schema_by_company(v_company_id) dv
           where exists(select ao.dvfc_id
                        from flow.get_data_view_field_configs(dv.id,
                                                              null,
                                                              new.custom_field_group_assignment_id) ao) and
               v_company_process_id = any(dv.company_process_ids)
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select a.*,lead(a.dvfc_id) OVER () IS NULL::boolean AS is_last_row
               from flow.get_data_view_field_configs(z.id,
                                                     null,
                                                     new.custom_field_group_assignment_id) a
        loop
          select *
          into v_sql
          from flow.execute_data_view_field_configs(x.contains_children,
                                                    case
                                                      when x.data_type_id = 1 then new.date_value::text
                                                      when x.data_type_id = 2 then new.timestamp_value::text
                                                      when x.data_type_id = 3 then new.boolean_value::text
                                                      when x.data_type_id = 4 then new.numeric_value::text
                                                      when x.data_type_id in (5,13) then new.text_value::text
                                                      when x.data_type_id = 6 then new.int_value::text
                                                      when x.data_type_id = 7 then new.int_array_value::text
                                                      when x.data_type_id in (8, 9) then new.int_value::text end,
                                                    x.dvfc_id,
                                                    new.id,
                                                    v_sql,
                                                    x.field_to_update,
                                                    x.update_first_value_only,
                                                    x.update_first_value_only_id,
                                                    x.is_last_row,
                                                    x.data_type_id);


        end loop;
      select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                   v_value, null::text, null::text,
                                                   x.update_first_value_only,
                                                   x.update_first_value_only_id,
                                                   false,
                                                   x.is_last_row, true, v_project_ids)
      into v_sql;
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(project_custom_field_value_id, error)
          values (new.id, SQLERRM);
      end;
    end loop;

  --TODO what to do here
  if (TG_OP = 'UPDATE') THEN
    select count(1)
    into v_count
    from flow.user_position up
           inner join flow.white_listed_position wlp on wlp.position_id = up.position_id and wlp.archived is false
    where up.user_id = coalesce(new.modified_by_id, new.created_by_id)
      and up.end_date is null
      and wlp.custom_field_group_assignment_id = 17280;
    if new.custom_field_group_assignment_id = 17280 and old.int_value != new.int_value and v_count < 1 then
      raise exception 'You do not have rights to update the Lead Source for this Contact (A).';
    end if;
  end if;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_project_custom_field_value_trg on flow.project_custom_field_value;
CREATE TRIGGER update_project_custom_field_value_trg
  after INSERT or update
  ON flow.project_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_custom_field_value_details();

CREATE OR REPLACE FUNCTION flow.update_project_process_step_details()
  RETURNS TRIGGER AS
$body$

declare
  v_project_id           integer;
  v_sql                  text;
  z                      record;
  x                      record;
  v_company_id           integer;
  v_project_ids          text;
  v_value                character varying;
  v_company_process_id integer;
BEGIN

  select p.id, c.company_id,p.company_process_id
  into v_project_id,v_company_id,v_company_process_id
  from flow.project p
         inner join flow.contact c on p.contact_id = c.id
  where p.id = new.project_id;

  select quote_literal(array_agg(v_project_id)::text)
  into v_project_ids;

  for z in select *
           from flow.get_schema_by_company(v_company_id) dv
           where exists(select ao.dvfc_id
                        from flow.get_data_view_field_configs(dv.id,
                                                              'PROCESS_STEP',
                                                              null) ao
                        where ao.process_step_id = new.process_step_id) and
               v_company_process_id = any(dv.company_process_ids)
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select a.*,lead(a.dvfc_id) OVER (order by a.update_first_value_only_id nulls last) IS NULL::boolean AS is_last_row
               from flow.get_data_view_field_configs(z.id,
                                                     'PROCESS_STEP',
                                                     null) a
               where process_step_id = new.process_step_id
               order by update_first_value_only_id nulls last

        loop
          execute format('SELECT $1.%I', x.column_name)
            into v_value using new;
          select *
          into v_sql
          from flow.execute_data_view_field_configs(x.contains_children,
                                                    v_value,
                                                    x.dvfc_id,
                                                    new.id,
                                                    v_sql,
                                                    x.field_to_update,
                                                    x.update_first_value_only,
                                                    x.update_first_value_only_id,
                                                    x.is_last_row,
                                                    x.data_type_id);

          if x.update_first_value_only is true then
            v_sql = trim(trailing ' ,' from v_sql);
            select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                         v_value::text, null::text, null::text,
                                                         x.update_first_value_only,
                                                         x.update_first_value_only_id,
                                                         false,
                                                         x.is_last_row, true, v_project_ids)
            into v_sql;
            begin
              execute v_sql;
            exception
              when others then
                insert into flow.trigger_error(project_process_step_id, error)
                values (new.id, SQLERRM);
            end;
            v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
          end if;

        end loop;
      if x.update_first_value_only is not true then
        select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                     v_value::text, null::text, null::text,
                                                     x.update_first_value_only,
                                                     x.update_first_value_only_id,
                                                     false,
                                                     x.is_last_row, true, v_project_ids)
        into v_sql;
        begin
          execute v_sql;
        exception
          when others then
            insert into flow.trigger_error(project_process_step_id, error)
            values (new.id, SQLERRM);
        end;
      end if;

    end loop;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_project_process_step_trg on flow.project_process_step;
CREATE TRIGGER update_project_process_step_trg
  after update or insert
  ON flow.project_process_step
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_process_step_details();


CREATE OR REPLACE FUNCTION flow.update_project_process_step_custom_field_value_details()
  RETURNS TRIGGER AS
$body$

declare
  v_project_ids text;
  v_project_id  integer;
  v_sql         character varying;
  v_value       character varying;
  v_project_id1 integer;
  v_company_id  integer;
  z             record;
  x             record;
  v_company_process_id integer;
BEGIN
  select pps.project_id, c.company_id
  into v_project_id,v_company_id
  from flow.project_process_step pps
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
  where pps.id = new.project_process_step_id
    and pps.main is true;

  select p.company_process_id
  into v_company_process_id
  from flow.project_process_step pps
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
  where pps.id = new.project_process_step_id;

  select pps.project_id, ps.company_id
  into v_project_id1,v_company_id
  from flow.project_process_step pps
         inner join flow.process_step ps on pps.process_step_id = ps.id
  where pps.id = new.project_process_step_id;

  select quote_literal(array_agg(coalesce(v_project_id, v_project_id1))::text)
  into v_project_ids;
  for z in select *
           from flow.get_schema_by_company(v_company_id) dv
           where exists(select ao.dvfc_id
                        from flow.get_data_view_field_configs(dv.id,
                                                              null,
                                                              new.custom_field_group_assignment_id) ao) and
             v_company_process_id = any(dv.company_process_ids)
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select a.*,lead(a.dvfc_id) OVER () IS NULL::boolean AS is_last_row
               from flow.get_data_view_field_configs(z.id,
                                                     null,
                                                     new.custom_field_group_assignment_id) a
        loop
          select *
          into v_sql
          from flow.execute_data_view_field_configs(x.contains_children,
                                                    case
                                                      when x.data_type_id = 1 then new.date_value::text
                                                      when x.data_type_id = 2 then new.timestamp_value::text
                                                      when x.data_type_id = 3 then new.boolean_value::text
                                                      when x.data_type_id = 4 then new.numeric_value::text
                                                      when x.data_type_id in (5,13) then new.text_value::text
                                                      when x.data_type_id = 6 then new.int_value::text
                                                      when x.data_type_id = 7 then new.int_array_value::text
                                                      when x.data_type_id in (8, 9) then new.int_value::text end,
                                                    x.dvfc_id,
                                                    new.id,
                                                    v_sql,
                                                    x.field_to_update,
                                                    x.update_first_value_only,
                                                    x.update_first_value_only_id,
                                                    x.is_last_row,
                                                    x.data_type_id);


        end loop;
      select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                   v_value, null::text, null::text,
                                                   x.update_first_value_only,
                                                   x.update_first_value_only_id,
                                                   false,
                                                   x.is_last_row, true, v_project_ids)
      into v_sql;
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(project_process_step_custom_value_id, error)
          values (new.id, SQLERRM);
      end;
    end loop;
  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists project_process_step_custom_field_value_trg on flow.project_process_step_custom_field_value;
CREATE TRIGGER project_process_step_custom_field_value_trg
  after INSERT or update
  ON flow.project_process_step_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_process_step_custom_field_value_details();

CREATE OR REPLACE FUNCTION flow.update_project_process_step_event_details()
  RETURNS TRIGGER AS
$body$

declare
  v_project_id           integer;
  v_sql                  text;
  z                      record;
  x                      record;
  v_company_id           integer;
  v_project_ids          text;
  v_value                character varying;
  v_event_status_type_id integer;
  v_company_process_id integer;
BEGIN

  select pps.project_id, c.company_id,p.company_process_id
  into v_project_id,v_company_id,v_company_process_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
  where ppse.id = new.id;

  select est.id
  into v_event_status_type_id
  from flow.company_event_status_type cest
         inner join flow.event_status_type est on cest.event_status_type_id = est.id
  where cest.id = new.company_event_status_type_id;


  if  old.company_event_status_type_id != new.company_event_status_type_id then
    if new.company_event_status_type_id is not null and v_event_status_type_id = 2 and new.completed_date is null then

      new.cancelled_date = null;
      new.completed_date = now();
    elseif new.company_event_status_type_id is not null and v_event_status_type_id = 3 and new.cancelled_date is null then
      new.cancelled_date = now();
      new.completed_date = null;
    else
      new.cancelled_date = null;
      new.completed_date = null;
    end if;
  end if;


  if (old.start_time is null and new.start_time is not null and (TG_OP = 'UPDATE')) then
    new.scheduled_date = now();
  end if;

  select quote_literal(array_agg(coalesce(v_project_id, v_project_id))::text)
  into v_project_ids;

  for z in select *
           from flow.get_schema_by_company(v_company_id) dv
           where exists(select ao.dvfc_id
                        from flow.get_data_view_field_configs(dv.id,
                                                              'EVENT',
                                                              null) ao
                        where ao.process_step_event_id = new.process_step_event_id) and
               v_company_process_id = any(dv.company_process_ids)
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select a.*,lead(a.dvfc_id) OVER (order by a.update_first_value_only_id nulls last) IS NULL::boolean AS is_last_row
               from flow.get_data_view_field_configs(z.id,
                                                     'EVENT',
                                                     null) a
               where process_step_event_id = new.process_step_event_id
               order by update_first_value_only_id nulls last

        loop
          execute format('SELECT $1.%I', x.column_name)
            into v_value using new;

          select *
          into v_sql
          from flow.execute_data_view_field_configs(x.contains_children,
                                                    v_value,
                                                    x.dvfc_id,
                                                    new.id,
                                                    v_sql,
                                                    x.field_to_update,
                                                    x.update_first_value_only,
                                                    x.update_first_value_only_id,
                                                    x.is_last_row,
                                                    x.data_type_id);

          if x.update_first_value_only is true then
            v_sql = trim(trailing ' ,' from v_sql);
            select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                         v_value::text, null::text, null::text,
                                                         x.update_first_value_only,
                                                         x.update_first_value_only_id,
                                                         false,
                                                         x.is_last_row, true, v_project_ids)
            into v_sql;
            begin
              execute v_sql;
            exception
              when others then
                insert into flow.trigger_error(project_process_step_event_id, error)
                values (new.id, SQLERRM);
            end;
            v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
          end if;

        end loop;
      if x.update_first_value_only is not true then
        select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                     v_value::text, null::text, null::text,
                                                     x.update_first_value_only,
                                                     x.update_first_value_only_id,
                                                     false,
                                                     x.is_last_row, true, v_project_ids)
        into v_sql;
        begin
          execute v_sql;
        exception
          when others then
            insert into flow.trigger_error(project_process_step_event_id, error)
            values (new.id, SQLERRM);
        end;
      end if;

    end loop;

  if new.process_step_event_id = 14 then
    if new.start_time is not null then
      perform flow.company_event_specific_tasks(v_company_id,
                                                new.resource_id,
                                                new.id,
                                                v_project_id,
                                                'UPDATE_APPOINTMENT_DATA',
                                                new.start_time);
    end if;
    if
      ((old.resource_id is null and new.resource_id is not null) or
       (old.resource_id != new.resource_id)) then
      perform flow.company_event_specific_tasks(v_company_id,
                                                new.resource_id,
                                                new.id,
                                                v_project_id,
                                                'UPDATE_OWNER_ON_PROJECT');
    end if;
  end if;

  RETURN new;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_project_process_step_event_trg on flow.project_process_step_event;
CREATE TRIGGER update_project_process_step_event_trg
  before update
  ON flow.project_process_step_event
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_process_step_event_details();


CREATE OR REPLACE FUNCTION flow.update_project_process_step_event_custom_field_value_details()
  RETURNS TRIGGER AS
$body$

declare
  v_project_id  integer;
  v_sql         character varying;
  v_value       character varying;
  v_project_id1 integer;
  z             record;
  x             record;
  v_company_id  integer;
  v_project_ids text;
  v_company_process_id integer;
BEGIN

  select pps.project_id, c.company_id
  into v_project_id,v_company_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
  where ppse.id = new.project_process_step_event_id
    and pps.main is true;

  select p.company_process_id
  into v_company_process_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
  where ppse.id = new.project_process_step_event_id;

  select pps.project_id, c.company_id
  into v_project_id1,v_company_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join flow.process_step ps on pps.process_step_id = ps.id
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
  where ppse.id = new.project_process_step_event_id;

  select quote_literal(array_agg(coalesce(v_project_id, v_project_id1))::text)
  into v_project_ids;

  for z in select *
           from flow.get_schema_by_company(v_company_id) dv
           where exists(select ao.dvfc_id
                        from flow.get_data_view_field_configs(dv.id,
                                                              null,
                                                              new.custom_field_group_assignment_id) ao
                               inner join flow.project_process_step_event ppse on id = new.project_process_step_event_id
                          and ao.process_step_event_id = ppse.process_step_event_id) and
               v_company_process_id = any(dv.company_process_ids)
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select dvfc.*,lead(dvfc.dvfc_id) OVER () IS NULL::boolean AS is_last_row
               from flow.get_data_view_field_configs(z.id,
                                                     null,
                                                     new.custom_field_group_assignment_id) dvfc
              inner join flow.project_process_step_event ppse on id = new.project_process_step_event_id
                              and dvfc.process_step_event_id = ppse.process_step_event_id

        loop
          select *
          into v_sql
          from flow.execute_data_view_field_configs(x.contains_children,
                                                    case
                                                      when x.data_type_id = 1 then new.date_value::text
                                                      when x.data_type_id = 2 then new.timestamp_value::text
                                                      when x.data_type_id = 3 then new.boolean_value::text
                                                      when x.data_type_id = 4 then new.numeric_value::text
                                                      when x.data_type_id in (5,13) then new.text_value::text
                                                      when x.data_type_id = 6 then new.int_value::text
                                                      when x.data_type_id = 7 then new.int_array_value::text
                                                      when x.data_type_id in (8, 9) then new.int_value::text end,
                                                    x.dvfc_id,
                                                    new.id,
                                                    v_sql,
                                                    x.field_to_update,
                                                    x.update_first_value_only,
                                                    x.update_first_value_only_id,
                                                    x.is_last_row,
                                                    x.data_type_id);


        end loop;
      select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                   v_value, null::text, null::text,
                                                   x.update_first_value_only,
                                                   x.update_first_value_only_id,
                                                   false,
                                                   x.is_last_row, true, v_project_ids)
      into v_sql;
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(project_process_step_event_custom_field_value_id, error)
          values (new.id, SQLERRM);
      end;
    end loop;

  if new.custom_field_group_assignment_id in (4, 21506) then
    perform flow.company_custom_field_event_specific_tasks(v_company_id,
                                                           new.project_process_step_event_id,
                                                           coalesce(v_project_id, v_project_id1));
  end if;
  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;


drop trigger if exists update_project_process_step_event_custom_field_value_trg on flow.project_process_step_event_custom_field_value;
CREATE TRIGGER update_project_process_step_event_custom_field_value_trg
  after INSERT or update
  ON flow.project_process_step_event_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_process_step_event_custom_field_value_details();



CREATE OR REPLACE FUNCTION flow.reset_data_view_columns_from_process_step()
  RETURNS TRIGGER AS
$body$

declare
  v_sql                     text;
  v_old_process_steps_found bigint;
  v_count                   integer = 0;
  z                         record;
  x                         record;
  v_company_id              integer;
  v_project_id              integer;
  v_value                   text;
  v_project_ids             text;
BEGIN

  select count(1)
  into v_old_process_steps_found
  from flow.project_process_step
  where process_step_id = new.process_step_id
    and project_id = new.project_id
    and id != new.id
    and main is false
    and new.main is true;
  v_count = 0;
  if ((TG_OP = 'INSERT') and new.main is true and v_old_process_steps_found > 0) or
     (TG_OP = 'UPDATE') and old.main is false and new.main is true then
    select c.company_id, p.id
    into v_company_id,v_project_id
    from flow.project p
           inner join flow.contact c on p.contact_id = c.id
    where new.project_id = p.id;

    select quote_literal(array_agg(v_project_id)::text)
    into v_project_ids;

    for z in select dv.company_process_ids,
                    dv.schema_name,
                    dv.view_name,
                    dvfc.field_to_update,
                    dvfc.id,
                    flow.get_prepared_value(cdt.data_type_id, null) as value
             from flow.get_schema_by_company(v_company_id) dv
                    inner join flow.data_view_field_config dvfc on dvfc.data_view_id = dv.id
                    inner join flow.custom_field_group_assignment cfga
                               on dvfc.custom_field_group_assignment_id = cfga.id and cfga.archived is false
                    inner join flow.custom_field cf on cfga.custom_field_id = cf.id and cf.archived is false
                    inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                    inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and
                                                              cfg.process_step_id = new.process_step_id and
                                                              cfg.archived is false
                    inner join flow.process_step ps on cfg.process_step_id = ps.id and
                                                       ps.archived is false and
                                                       exists(select psp.id
                                                              from flow.process_step_process psp
                                                                     inner join flow.company_process cp
                                                                                on psp.company_process_id = cp.id and
                                                                                   cp.company_id = v_company_id and
                                                                                   cp.archived is false
                                                              where psp.process_step_id = ps.id
                                                                and psp.archived is false
                                                                and cp.id = any (dv.company_process_ids))

             where dvfc.reset_on_new is true
               and dvfc.update_first_value_only is false
             union
             select dv.company_process_ids,
                    dv.schema_name,
                    dv.view_name,
                    dvfc.field_to_update,
                    dvfc.id,
                    flow.get_prepared_value(df.data_type_id, null) as value
             from flow.get_schema_by_company(v_company_id) dv
                    inner join flow.data_view_field_config dvfc on dvfc.data_view_id = dv.id
                    inner join flow.default_field df on dvfc.default_field_id = df.id
                    inner join flow.process_step ps
                               on dvfc.process_step_id = ps.id and dvfc.process_step_id = new.process_step_id and
                                  exists(select psp.id
                                         from flow.process_step_process psp
                                                inner join flow.company_process cp on psp.company_process_id = cp.id and
                                                                                      cp.company_id = v_company_id and
                                                                                      cp.archived is false
                                         where psp.process_step_id = ps.id
                                           and psp.archived is false
                                           and cp.id = any (dv.company_process_ids))

             where dvfc.reset_on_new is true
               and dvfc.update_first_value_only is false
      loop
        if v_count = 0 then
          v_sql = NULL;
          v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
        end if;
        v_count = v_count + 1;
        v_sql = v_sql || z.field_to_update || $$ = $$ || z.value || $$ ,$$;

        for x in select dvcfc.field_to_update,
                        flow.get_prepared_value(dvcfc.data_type_id, null) as value
                 from flow.data_view_child_field_config dvcfc
                 where dvcfc.data_view_field_config_id = z.id
          loop
            v_sql = v_sql || x.field_to_update || $$ = $$ || z.value || $$ ,$$;
          end loop;
      end loop;
    v_sql = trim(trailing ' ,' from v_sql);
    v_sql = v_sql || ' where project_id = ' || v_project_id || ';';
    if v_count > 0 then
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(project_process_step_id, error)
          values (new.id, SQLERRM);
      end;
    end if;
  end if;


  if (TG_OP = 'UPDATE') and old.main is false and new.main is true then
    v_count = 0;
    for z in select ppscfv.id                                                         as ppscfv_id,
                    dv.id                                                             as data_view_id,
                    dv.schema_name,
                    dv.view_name,
                    dvfc.field_to_update,
                    dvfc.id,
                    cfga.id                                                           as custom_field_group_assignment_id,
                    case
                      when cdt.data_type_id = 1 then ppscfv.date_value::text
                      when cdt.data_type_id = 2 then ppscfv.timestamp_value::text
                      when cdt.data_type_id = 3 then ppscfv.boolean_value::text
                      when cdt.data_type_id = 4 then ppscfv.numeric_value::text
                      when cdt.data_type_id = 5 then ppscfv.text_value::text
                      when cdt.data_type_id = 6 then ppscfv.int_value::text
                      when cdt.data_type_id = 7 then ppscfv.int_array_value::text
                      when cdt.data_type_id in (8, 9) then ppscfv.int_value::text end as value
             from flow.get_schema_by_company(v_company_id) dv
                    inner join flow.data_view_field_config dvfc on dvfc.data_view_id = dv.id
                    inner join flow.custom_field_group_assignment cfga
                               on dvfc.custom_field_group_assignment_id = cfga.id and cfga.archived is false
                    inner join flow.custom_field cf on cfga.custom_field_id = cf.id and cf.archived is false
                    inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                    inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id and
                                                              cfg.process_step_id = new.process_step_id and
                                                              cfg.archived is false
                    inner join flow.process_step ps on cfg.process_step_id = ps.id and
                                                       ps.archived is false and
                                                       exists(select psp.id
                                                              from flow.process_step_process psp
                                                                     inner join flow.company_process cp
                                                                                on psp.company_process_id = cp.id and
                                                                                   cp.company_id = v_company_id and
                                                                                   cp.archived is false
                                                              where psp.process_step_id = ps.id
                                                                and psp.archived is false
                                                                and cp.id = any (dv.company_process_ids))
                    inner join flow.project_process_step_custom_field_value ppscfv
                               on cfga.id = ppscfv.custom_field_group_assignment_id and
                                  ppscfv.project_process_step_id = new.id
             where dvfc.reset_on_new is true
               and dvfc.update_first_value_only is false

      loop
        v_sql = NULL;
        v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
        for x in select a.*, lead(a.dvfc_id) OVER () IS NULL::boolean AS is_last_row
                 from flow.get_data_view_field_configs(z.data_view_id,
                                                       null,
                                                       z.custom_field_group_assignment_id) a
          loop
            v_count = 1;
            select *
            into v_sql
            from flow.execute_data_view_field_configs(x.contains_children,
                                                      z.value::text,
                                                      x.dvfc_id,
                                                      z.ppscfv_id,
                                                      v_sql,
                                                      x.field_to_update,
                                                      x.update_first_value_only,
                                                      x.update_first_value_only_id,
                                                      x.is_last_row,
                                                      x.data_type_id);


          end loop;
        -- raise notice 'this is the v_sql %',v_sql;
        select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                     v_value, null::text, null::text,
                                                     x.update_first_value_only,
                                                     x.update_first_value_only_id,
                                                     false,
                                                     x.is_last_row, true, v_project_ids)
        into v_sql;

        if v_count > 0 then
          begin
            execute v_sql;
          exception
            when others then
              insert into flow.trigger_error(project_process_step_id, error)
              values (new.id, SQLERRM);
          end;
        end if;

      end loop;

    for z in select dv.id as data_view_id,
                    dv.schema_name,
                    dv.view_name,
                    dvfc.field_to_update,
                    dvfc.id
             from flow.get_schema_by_company(v_company_id) dv
                    inner join flow.data_view_field_config dvfc on dvfc.data_view_id = dv.id
                    inner join flow.default_field df on dvfc.default_field_id = df.id
                    inner join flow.process_step ps on dvfc.process_step_id = ps.id and
                                                       ps.archived is false and
                                                       exists(select psp.id
                                                              from flow.process_step_process psp
                                                                     inner join flow.company_process cp
                                                                                on psp.company_process_id = cp.id and
                                                                                   cp.company_id = v_company_id and
                                                                                   cp.archived is false
                                                              where psp.process_step_id = ps.id
                                                                and psp.archived is false
                                                                and cp.id = any (dv.company_process_ids))
             where dvfc.reset_on_new is true
               and dvfc.update_first_value_only is false

      loop
        v_sql = NULL;
        v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
        for x in select a.*, lead(a.dvfc_id) OVER () IS NULL::boolean AS is_last_row
                 from flow.get_data_view_field_configs(z.data_view_id,
                                                       'PROCESS_STEP',
                                                       null) a
          loop
            v_count = 1;
            execute format('SELECT $1.%I', x.column_name)
              into v_value using new;
            select *
            into v_sql
            from flow.execute_data_view_field_configs(x.contains_children,
                                                      v_value::text,
                                                      x.dvfc_id,
                                                      new.id,
                                                      v_sql,
                                                      x.field_to_update,
                                                      x.update_first_value_only,
                                                      x.update_first_value_only_id,
                                                      x.is_last_row,
                                                      x.data_type_id);


          end loop;
        -- raise notice 'this is the v_sql %',v_sql;
        select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                     v_value, null::text, null::text,
                                                     x.update_first_value_only,
                                                     x.update_first_value_only_id,
                                                     false,
                                                     x.is_last_row, true, v_project_ids)
        into v_sql;

        if v_count > 0 then
          begin
            execute v_sql;
          exception
            when others then
              insert into flow.trigger_error(project_process_step_id, error)
              values (new.id, SQLERRM);
          end;
        end if;
      end loop;

  end if;
  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists reset_data_view_columns_from_process_step_trg on flow.project_process_step;
CREATE TRIGGER reset_data_view_columns_from_process_step_trg
  after INSERT or update
  ON flow.project_process_step
  FOR EACH ROW
EXECUTE PROCEDURE flow.reset_data_view_columns_from_process_step();



CREATE OR REPLACE FUNCTION flow.reset_data_view_columns_from_process_step_event()
  RETURNS TRIGGER AS
$body$

declare
  v_sql                           text;
  v_old_process_steps_event_found bigint;
  v_count                         integer = 0;
  z                               record;
  x                               record;
  v_company_id                    integer;
  v_project_id                    integer;
  v_project_ids                   text;
BEGIN

  select count(1)
  into v_old_process_steps_event_found
  from flow.project_process_step_event
  where process_step_event_id = new.process_step_event_id
    and project_process_step_id = new.project_process_step_id
    and id != new.id;
  v_count = 0;


  if ((TG_OP = 'INSERT') and v_old_process_steps_event_found > 0) then
    select c.company_id, p.id
    into v_company_id,v_project_id
    from flow.project_process_step pps
           inner join flow.project p on pps.project_id = p.id
           inner join flow.contact c on p.contact_id = c.id
    where pps.id = new.project_process_step_id;

    select quote_literal(array_agg(v_project_id)::text)
    into v_project_ids;

    for z in select dv.schema_name,
                    dv.view_name,
                    dvfc.field_to_update,
                    dvfc.id,
                    flow.get_prepared_value(cdt.data_type_id, null) as value
             from flow.get_schema_by_company(v_company_id) dv
                    inner join flow.data_view_field_config dvfc on dvfc.data_view_id = dv.id
                    inner join flow.custom_field_group_assignment cfga
                               on dvfc.custom_field_group_assignment_id = cfga.id
                    inner join flow.process_step_event pse on pse.id = new.process_step_event_id and
                                                              dvfc.process_step_event_id = pse.id and
                                                              pse.archived is false
                    inner join flow.process_step ps on pse.process_step_id = ps.id and
                                                       ps.archived is false and
                                                       exists(select psp.id
                                                              from flow.process_step_process psp
                                                                     inner join flow.company_process cp
                                                                                on psp.company_process_id = cp.id and
                                                                                   cp.company_id = v_company_id and
                                                                                   cp.archived is false
                                                              where psp.process_step_id = ps.id
                                                                and psp.archived is false
                                                                and cp.id = any (dv.company_process_ids))
                    inner join flow.custom_field cf on cfga.custom_field_id = cf.id and cf.archived is false
                    inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
             where dvfc.reset_on_new is true
               and dvfc.update_first_value_only is false
             union
             select dv.schema_name,
                    dv.view_name,
                    dvfc.field_to_update,
                    dvfc.id,
                    flow.get_prepared_value(dt.id, null) as value
             from flow.get_schema_by_company(v_company_id) dv
                    inner join flow.data_view_field_config dvfc on dvfc.data_view_id = dv.id
                    inner join flow.process_step_event pse on pse.id = new.process_step_event_id and
                                                              dvfc.process_step_event_id = pse.id and
                                                              pse.archived is false
                    inner join flow.process_step ps on pse.process_step_id = ps.id and
                                                       ps.archived is false and
                                                       exists(select psp.id
                                                              from flow.process_step_process psp
                                                                     inner join flow.company_process cp
                                                                                on psp.company_process_id = cp.id and
                                                                                   cp.company_id = v_company_id and
                                                                                   cp.archived is false
                                                              where psp.process_step_id = ps.id
                                                                and psp.archived is false
                                                                and cp.id = any (dv.company_process_ids))
                    inner join flow.default_field df on dvfc.default_field_id = df.id
                    inner join flow.data_type dt on df.data_type_id = dt.id
             where dvfc.reset_on_new is true
               and dvfc.update_first_value_only is false

      loop
        if v_count = 0 then
          v_sql = NULL;
          v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
        end if;
        v_count = v_count + 1;
        v_sql = v_sql || z.field_to_update || $$ = $$ || z.value || $$ ,$$;

        for x in select dvcfc.field_to_update,
                        flow.get_prepared_value(dvcfc.data_type_id, null) as value
                 from flow.data_view_child_field_config dvcfc
                 where dvcfc.data_view_field_config_id = z.id
          loop
            v_sql = v_sql || x.field_to_update || $$ = $$ || z.value || $$ ,$$;
          end loop;
      end loop;
    v_sql = trim(trailing ' ,' from v_sql);
    v_sql = v_sql || ' where project_id = ' || v_project_id || ';';
    if v_count > 0 then
      begin
        execute v_sql;
      exception
        when others then
          insert into flow.trigger_error(project_process_step_event_id, error)
          values (new.id, SQLERRM);
      end;
    end if;
  end if;
  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists reset_data_view_columns_from_process_step_trg on flow.project_process_step_event;
CREATE TRIGGER reset_data_view_columns_from_process_step_trg
  after INSERT or update
  ON flow.project_process_step_event
  FOR EACH ROW
EXECUTE PROCEDURE flow.reset_data_view_columns_from_process_step_event();
