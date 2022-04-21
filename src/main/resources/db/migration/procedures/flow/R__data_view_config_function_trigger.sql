CREATE OR REPLACE FUNCTION flow.contact_details()
  RETURNS TRIGGER AS
$body$
declare
  v_project_ids       text;
  x                   record;
  v_sql               text;
  z                   record;
  v_value             text;
BEGIN
  select quote_literal(array_agg(id)::text)
  into v_project_ids
  from flow.project
  where contact_id = new.id;

  if v_project_ids is not null then
    for z in select * from brs.get_schema_by_company(new.company_id)
      loop
        v_sql = NULL;
        v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
        for x in select * from brs.get_data_view_field_configs(z.id,
                                                               'CONTACT')
          loop
            execute format('SELECT $1.%I', x.column_name)
              into v_value using new;
            select *
            into v_sql
            from brs.execute_data_view_field_configs(x.contains_children,
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
                                                     v_value, null, null,
                                                     x.update_first_value_only,
                                                     x.update_first_value_only_id,
                                                     x.is_last_row, true, v_project_ids)
        into v_sql;
        -- begin
        execute v_sql;
        -- exception
        --   when others then
        --    insert into flow.trigger_error(project_process_step_custom_value_id, error)
        --    values (new.id, SQLERRM);
        --end;
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

CREATE OR REPLACE FUNCTION flow.project_details()
  RETURNS TRIGGER AS
$body$
declare
  x              record;
  v_sql          text;
  z              record;
  v_company_id   integer;
  v_project_ids  text;
  v_value        text;
BEGIN
  select company_id
  into v_company_id
  from flow.company_process cp
  where process_id = new.company_process_id
  limit 1;

  IF (TG_OP = 'INSERT') THEN
    insert into brs.project_details(project_id, company_id, contact_id)
    values (new.id, v_company_id, new.contact_id);
    update flow.contact set id = id where id = new.contact_id;
  end if;

  select quote_literal(array_agg(new.id)::text)
  into v_project_ids;

  for z in select * from brs.get_schema_by_company(v_company_id)
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select * from brs.get_data_view_field_configs(z.id,
                                                             'PROJECT')
        loop
          execute format('SELECT $1.%I', x.column_name)
            into v_value using new;
          select *
          into v_sql
          from brs.execute_data_view_field_configs(x.contains_children,
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
                                           v_value, null, null,
                                           x.update_first_value_only,
                                           x.update_first_value_only_id,
                                           x.is_last_row, true, v_project_ids)
      into v_sql;
     --- begin
        execute v_sql;
     -- exception
      --  when others then
       --   insert into flow.trigger_error(project_process_step_custom_value_id, error)
        --  values (new.id, SQLERRM);
      --end;
    end loop;
  perform brs.company_project_specific_tasks(v_company_id, new.company_project_status_type_id,
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


CREATE OR REPLACE FUNCTION flow.update_project_process_step_custom_field_value_details()
  RETURNS TRIGGER AS
$body$

declare
  v_project_ids  text;
  v_project_id   integer;
  v_sql          character varying;
  v_value        character varying;
  v_second_value text;
  v_project_id1  integer;
  v_company_id   integer;
  z              record;
  x              record;
BEGIN

  select pps.project_id, c.company_id
  into v_project_id,v_company_id
  from flow.project_process_step pps
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
  where pps.id = new.project_process_step_id
    and pps.main is true;

  select pps.project_id, ps.company_id
  into v_project_id1,v_company_id
  from flow.project_process_step pps
         inner join flow.process_step ps on pps.process_step_id = ps.id
  where pps.id = new.project_process_step_id;

  select quote_literal(array_agg(coalesce(v_project_id, v_project_id1))::text)
  into v_project_ids;
  for z in select c.schema_name, dv.view_name, dv.id
           from flow.company c
                  inner join flow.data_view dv on c.id = dv.company_id
           where c.id = v_company_id
           and exists (select dvfc2.id
                      from flow.data_view_field_config dvfc2
                      inner join flow.field_config fc2 on dvfc2.field_config_id = fc2.id
                      where dvfc2.data_view_id = dv.id and fc2.custom_field_group_assignment_id = new.custom_field_group_assignment_id
                      )
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select fc.field_to_update,
                      fc.secondary_field,
                      fc.secondary_data_type_id,
                      fc.update_first_value_only,
                      fc.update_first_value_only_id,
                      cf.id                                as custom_field_id,
                      cf.field_name,
                      cf.list_of_value_id,
                      cf.system_list_option_ids,
                      cf.company_system_list_id,
                      cf.custom_field_sql_reference_table,
                      cf.custom_field_sql_column,
                      dt.id                                as data_type_id,
                      lead(fc.id) OVER () IS NULL::boolean AS is_last_row
               from flow.data_view_field_config dvfc
                      inner join flow.field_config fc on fc.id = dvfc.field_config_id
                      inner join flow.custom_field_group_assignment cfga
                                 on fc.custom_field_group_assignment_id = cfga.id
                      inner join flow.custom_field cf on cfga.custom_field_id = cf.id
                      inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                      inner join flow.data_type dt on cdt.data_type_id = dt.id
               where cfga.id = new.custom_field_group_assignment_id and dvfc.data_view_id = z.id
        loop
          if x.secondary_field is not null and x.data_type_id = 2 and x.secondary_data_type_id = 1 then
             case when new.timestamp_value is null then select 'null' into v_second_value; else select quote_literal(new.timestamp_value) into v_second_value; end case;
             v_second_value = '(' || v_second_value || '::timestamp at time zone ' || quote_literal('UTC') ||
                       ' at time zone ' || quote_literal('US/Mountain') || ')::date';
          elsif x.secondary_field is not null then
            select flow.get_secondary_detail_value(x.list_of_value_id,
                                                   x.company_system_list_id,
                                                   new.int_value,
                                                   x.custom_field_sql_column,
                                                   x.custom_field_sql_reference_table)
            into v_second_value;
            select flow.get_prepared_value(x.secondary_data_type_id, v_second_value)
            into v_second_value;
          end if;

          select flow.get_prepared_value(x.data_type_id, case
                                                           when x.data_type_id = 1 then new.date_value::text
                                                           when x.data_type_id = 2 then new.timestamp_value::text
                                                           when x.data_type_id = 3 then new.boolean_value::text
                                                           when x.data_type_id = 4 then new.numeric_value::text
                                                           when x.data_type_id = 5 then new.text_value::text
                                                           when x.data_type_id = 6 then new.int_value::text
                                                           when x.data_type_id = 7 then new.int_array_value::text
                                                           when x.data_type_id in (8,9) then new.int_value::text end)
          into v_value;
          select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                       v_value, x.secondary_field, v_second_value,
                                                       x.update_first_value_only,
                                                       x.update_first_value_only_id,
                                                       x.is_last_row)
          into v_sql;

        end loop;
      select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                   v_value, x.secondary_field, v_second_value,
                                                   x.update_first_value_only,
                                                   x.update_first_value_only_id,
                                                   x.is_last_row, true, v_project_ids)
      into v_sql;
     -- begin
        execute v_sql;
     -- exception
       -- when others then
         -- insert into flow.trigger_error(project_process_step_custom_value_id, error)
         -- values (new.id, SQLERRM);
      --end;
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



CREATE OR REPLACE FUNCTION flow.update_project_process_step_event_custom_field_value_details()
  RETURNS TRIGGER AS
$body$

declare
  v_project_id              integer;
  v_sql                     character varying;
  v_value                   character varying;
  v_project_id1             integer;
  z record;
  x record;
  v_company_id integer;
  v_project_ids  text;
  v_second_value text;
BEGIN

  select pps.project_id,c.company_id
  into v_project_id,v_company_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join flow.project p on pps.project_id = p.id
          inner join flow.contact c on p.contact_id = c.id
  where ppse.id = new.project_process_step_event_id
    and pps.main is true;

  select pps.project_id,c.company_id
  into v_project_id1,v_company_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
         inner join flow.process_step ps on pps.process_step_id = ps.id
         inner join flow.project p on pps.project_id = p.id
         inner join flow.contact c on p.contact_id = c.id
  where ppse.id = new.project_process_step_event_id;

  select quote_literal(array_agg(coalesce(v_project_id, v_project_id1))::text)
  into v_project_ids;

  for z in select c.schema_name, dv.view_name, dv.id
           from flow.company c
                  inner join flow.data_view dv on c.id = dv.company_id
           where c.id = v_company_id
             and exists (select dvfc2.id
                         from flow.data_view_field_config dvfc2
                                inner join flow.field_config fc2 on dvfc2.field_config_id = fc2.id
                         where dvfc2.data_view_id = dv.id and fc2.custom_field_group_assignment_id = new.custom_field_group_assignment_id
             )
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select fc.field_to_update,
                      fc.secondary_field,
                      fc.secondary_data_type_id,
                      fc.update_first_value_only,
                      fc.update_first_value_only_id,
                      cf.id                                as custom_field_id,
                      cf.field_name,
                      cf.list_of_value_id,
                      cf.system_list_option_ids,
                      cf.company_system_list_id,
                      cf.custom_field_sql_reference_table,
                      cf.custom_field_sql_column,
                      dt.id                                as data_type_id,
                      lead(fc.id) OVER () IS NULL::boolean AS is_last_row
               from flow.data_view_field_config dvfc
                      inner join flow.field_config fc on fc.id = dvfc.field_config_id
                      inner join flow.custom_field_group_assignment cfga
                                 on fc.custom_field_group_assignment_id = cfga.id
                      inner join flow.custom_field cf on cfga.custom_field_id = cf.id
                      inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
                      inner join flow.data_type dt on cdt.data_type_id = dt.id
               where cfga.id = new.custom_field_group_assignment_id and dvfc.data_view_id = z.id

        loop

          if v_company_id = 3 and new.custom_field_group_assignment_id in (4,21506) and z.view_name = 'project_details' then
            perform brs.company_event_specific_tasks(coalesce(v_project_id,v_project_id1),
                                                     new.project_process_step_event_id,
                                                     new.id,
                                                     new.int_value,
                                                     new.custom_field_group_assignment_id);
          end if;

          if x.secondary_field is not null and x.data_type_id = 2 and x.secondary_data_type_id = 1 then
            case when new.timestamp_value is null then select 'null' into v_second_value; else select quote_literal(new.timestamp_value) into v_second_value; end case;
            v_second_value = '(' || v_second_value || '::timestamp at time zone ' || quote_literal('UTC') ||
                             ' at time zone ' || quote_literal('US/Mountain') || ')::date';
          elsif x.secondary_field is not null then
            select flow.get_secondary_detail_value(x.list_of_value_id,
                                                   x.company_system_list_id,
                                                   new.int_value,
                                                   x.custom_field_sql_column,
                                                   x.custom_field_sql_reference_table)
            into v_second_value;
            select flow.get_prepared_value(x.secondary_data_type_id, v_second_value)
            into v_second_value;
          end if;

          select flow.get_prepared_value(x.data_type_id, case
                                                           when x.data_type_id = 1 then new.date_value::text
                                                           when x.data_type_id = 2 then new.timestamp_value::text
                                                           when x.data_type_id = 3 then new.boolean_value::text
                                                           when x.data_type_id = 4 then new.numeric_value::text
                                                           when x.data_type_id = 5 then new.text_value::text
                                                           when x.data_type_id = 6 then new.int_value::text
                                                           when x.data_type_id = 7 then new.int_array_value::text
                                                           when x.data_type_id in (8,9) then new.int_value::text end)
          into v_value;
          select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                       v_value, x.secondary_field, v_second_value,
                                                       x.update_first_value_only,
                                                       x.update_first_value_only_id,
                                                       x.is_last_row)
          into v_sql;

        end loop;
      select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                   v_value, x.secondary_field, v_second_value,
                                                   x.update_first_value_only,
                                                   x.update_first_value_only_id,
                                                   x.is_last_row, true, v_project_ids)
      into v_sql;
      -- begin
      execute v_sql;
      -- exception
      -- when others then
      -- insert into flow.trigger_error(project_process_step_custom_value_id, error)
      -- values (new.id, SQLERRM);
      --end;
    end loop;
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


CREATE OR REPLACE FUNCTION flow.update_project_process_step_event_details()
  RETURNS TRIGGER AS
$body$

declare
  v_project_id       integer;
  v_closer_name      varchar;
  v_user_id          integer;
  v_user_position_id integer;
  v_sql              text;
  z record;
  x record;
  v_company_id integer;
  v_project_ids  text;
  v_second_value text;
v_value  character varying;;
BEGIN

  select pps.project_id,c.company_id
  into v_project_id,v_company_id
  from flow.project_process_step_event ppse
         inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
        inner join flow.project p on pps.project_id = p.id
  inner join flow.contact c on p.contact_id = c.id
  where ppse.id = new.id;

  select quote_literal(array_agg(coalesce(v_project_id, v_project_id))::text)
  into v_project_ids;

  for z in select c.schema_name, dv.view_name, dv.id
           from flow.company c
                  inner join flow.data_view dv on c.id = dv.company_id
           where c.id = v_company_id
             and exists (select dvfc2.id
                         from flow.data_view_field_config dvfc2
                                inner join flow.field_config fc2 on dvfc2.field_config_id = fc2.id
                         where dvfc2.data_view_id = dv.id and fc2.process_step_event_id = new.id
             )
    loop
      v_sql = NULL;
      v_sql = $$update $$ || z.schema_name || $$.$$ || z.view_name || $$ set $$;
      for x in select fc.field_to_update,
                      fc.secondary_field,
                      fc.secondary_data_type_id,
                      fc.update_first_value_only,
                      fc.update_first_value_only_id,
                      df.column_name,
                      dt.data_type as data_type_id,
                      cf.company_system_list_id,
                      pse3.unique_behavior_type_id,
                      lead(fc.id) OVER () IS NULL::boolean AS is_last_row
               from flow.data_view_field_config dvfc
                      inner join flow.field_config fc on fc.id = dvfc.field_config_id
                      inner join flow.process_step_event pse3
                                 on fc.process_step_event_id = pse3.id
                      inner join flow.event e on pse3.event_id = e.id
                      inner join flow.custom_field cf on e.resource_custom_field_id = cf.id
                      inner join flow.default_field df on fc.default_field_id = df.id
                      inner join flow.data_type dt on df.data_type_id = dt.id
               where pse3.id = new.process_step_event_id and dvfc.data_view_id = z.id

        loop
          if x.secondary_field is not null and x.data_type_id = 2 and x.secondary_data_type_id = 1 then
            case when new.start_time is null then select 'null' into v_second_value; else select quote_literal(new.start_time) into v_second_value; end case;
            v_second_value = '(' || v_second_value || '::timestamp at time zone ' || quote_literal('UTC') ||
                             ' at time zone ' || quote_literal('US/Mountain') || ')::date';
          elsif x.secondary_field is not null then
            select flow.get_secondary_detail_value(null,
                                                   x.company_system_list_id,
                                                   new.resource_id,
                                                   null,
                                                   null)
            into v_second_value;
            select flow.get_prepared_value(x.secondary_data_type_id, v_second_value)
            into v_second_value;
          end if;

          select flow.get_prepared_value(case when x.column_name in ('end_time','start_time') then 2
                                                    else 6 end, case when x.column_name = 'end_time' then new.end_time
                                                                      when x.column_name = 'start_time' then new.start_time
                                                                      else new.resource_id end)
          into v_value;
          select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                       v_value, x.secondary_field, v_second_value,
                                                       x.update_first_value_only,
                                                       x.update_first_value_only_id,
                                                       x.is_last_row)
          into v_sql;

        end loop;
      select flow.prepare_update_data_view_details(new.id, v_sql, x.field_to_update,
                                                   v_value, x.secondary_field, v_second_value,
                                                   x.update_first_value_only,
                                                   x.update_first_value_only_id,
                                                   x.is_last_row, true, v_project_ids)
      into v_sql;
      -- begin
      execute v_sql;
      -- exception
      -- when others then
      -- insert into flow.trigger_error(project_process_step_custom_value_id, error)
      -- values (new.id, SQLERRM);
      --end;
    end loop;


  if v_count > 0 then
    select u.id, u.first_name || ' ' || u.last_name, up.id
    into v_user_id,v_closer_name,v_user_position_id
    from flow.user u
           inner join flow.user_position up on u.id = up.user_id and up.primary_flag is true
    where up.id = new.resource_id;

    update brs.project_details
    set first_appointment         = new.start_time,
        first_appointment_ppse_id = new.id
    where project_id = v_project_id
      and (first_appointment is null or
           (first_appointment_ppse_id is not null and first_appointment_ppse_id = new.id));
    update brs.project_details
    set closer_user_id          = v_user_id,
        closer_name             = v_closer_name,
        closer_user_position_id = v_user_position_id
    where project_id = v_project_id;
  end if;

  if ((old.resource_id is null and new.resource_id is not null) or
     (old.resource_id != new.resource_id)) and (v_unique_behavior_type_id is not null and v_unique_behavior_type_id = 1) then

    update flow.project p
    set user_position_id = new.resource_id,
        date_modified =  now()
    where p.id = v_project_id;
  end if;


  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_project_process_step_event_trg on flow.project_process_step_event;
CREATE TRIGGER update_project_process_step_event_trg
  after INSERT or update
  ON flow.project_process_step_event
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_process_step_event_details();


CREATE OR REPLACE FUNCTION flow.pps_update_project_details()
  RETURNS TRIGGER AS
$body$
declare
  v_parent_process_step_id integer;
BEGIN

  select ps.parent_process_step_id
  into v_parent_process_step_id
  from flow.process_step ps
  where new.process_step_id = ps.id;

  if v_parent_process_step_id = 3166 and new.process_step_complete_date is not null then
    update brs.project_details
    set complete_date_booking = new.process_step_complete_date
    where project_id = new.project_id
      and complete_date_booking is null;
  elsif v_parent_process_step_id = 3241 and new.process_step_complete_date is not null then
    update brs.project_details
    set complete_date_final_design_completion = new.process_step_complete_date
    where project_id = new.project_id
      and complete_date_final_design_completion is null;
  end if;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists pps_update_project_details_trg on flow.project_process_step;
CREATE TRIGGER pps_update_project_details_trg
  after INSERT or update
  ON flow.project_process_step
  FOR EACH ROW
EXECUTE PROCEDURE flow.pps_update_project_details();


CREATE OR REPLACE FUNCTION flow.update_project_details_project()
  RETURNS TRIGGER AS
$body$

declare
    v_field_to_update        character varying;
    v_data_type_id           integer;
    v_config_id              integer;
    v_sql                    character varying;
    v_value                  character varying;
    v_second_field_to_update character varying;
    v_count                  integer;
BEGIN

  select pdc.id, field_to_update, data_type_id, second_field_to_update
  into v_config_id,v_field_to_update,v_data_type_id,v_second_field_to_update
  from brs.project_details_config pdc
  where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id;


  if v_config_id is not null and v_data_type_id in (1, 2, 3, 4, 6, 5) then
    if v_data_type_id = 1 then
      case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
      v_value = v_value || '::date';
    elsif v_data_type_id = 2 then
      case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
      v_value = v_value || '::timestamp';
    elsif v_data_type_id = 4 then
      case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
      v_value = v_value || '::numeric';
    elsif v_data_type_id = 6 then
      case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
      v_value = v_value || '::integer';
    elsif v_data_type_id = 5 then
      case when new.text_value is null then select 'null' into v_value; else select quote_literal(new.text_value) into v_value; end case;
      v_value = v_value || '::text';
    elsif v_data_type_id = 3 then
      case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
      v_value = v_value || '::boolean';
    end if;

    v_sql = $$update brs.project_details set $$ || v_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || new.project_id;
    -- raise notice 'in if %',v_sql;
    execute v_sql;

    if v_second_field_to_update is not null then
      if v_field_to_update = 'ahj' and new.int_value is not null then
        select quote_literal(ahj.name)
        into v_value
        from brs.ahj ahj
        where ahj.id = new.int_value
        limit 1;
      elsif v_field_to_update = 'utility_company' and new.int_value is not null then
        select quote_literal(au.name)
        into v_value
        from brs.ahj_utility au
        where au.id = new.int_value
        limit 1;
      elsif v_field_to_update = 'sales_dev_representative_id' or v_field_to_update = 'inside_sales_consultant_id' then
        case when new.int_value is null then select 'null' into v_value;
          else
            select quote_literal(coalesce(u.first_name, ' ') || ' ' || coalesce(u.last_name, ' '))
            into v_value
            from flow.user_position up
                   inner join flow.user u on up.user_id = u.id
            where up.id = new.int_value;
          end case;
      else
        case when new.int_value is null then select 'null' into v_value;
          else
            select quote_literal(name)
            into v_value
            from flow.list_of_value
            where id = new.int_value;
          end case;
      end if;
      v_sql = $$update brs.project_details set $$ || v_second_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || new.project_id;
            execute v_sql;
        end if;
    end if;

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

drop trigger if exists update_project_details_project_trg on flow.project_custom_field_value;
CREATE TRIGGER update_project_details_project_trg
  after INSERT or update
  ON flow.project_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_project_details_project();


CREATE OR REPLACE FUNCTION flow.update_contact_details_project_details()
  RETURNS TRIGGER AS
$body$

declare
  v_field_to_update character varying;
  v_data_type_id    integer;
  v_config_id       integer;
  v_sql             character varying;
  v_value           character varying;
  v_record          record;
  v_count           bigint;
BEGIN


  select pdc.id, field_to_update, data_type_id
  into v_config_id,v_field_to_update,v_data_type_id
  from brs.project_details_config pdc
  where pdc.custom_field_group_assignment_id = new.custom_field_group_assignment_id;


  if v_config_id is not null and v_data_type_id in (1, 2, 3, 4, 6) then
    if v_data_type_id = 1 then
      case when new.date_value is null then select 'null' into v_value; else select quote_literal(new.date_value) into v_value; end case;
      v_value = v_value || '::date';
    elsif v_data_type_id = 2 then
      case when new.timestamp_value is null then select 'null' into v_value; else select quote_literal(new.timestamp_value) into v_value; end case;
      v_value = v_value || '::timestamp';
    elsif v_data_type_id = 4 then
      case when new.numeric_value is null then select 'null' into v_value; else select quote_literal(new.numeric_value) into v_value; end case;
      v_value = v_value || '::numeric';
    elsif v_data_type_id = 6 then
      case when new.int_value is null then select 'null' into v_value; else select quote_literal(new.int_value) into v_value; end case;
      v_value = v_value || '::integer';
    elsif v_data_type_id = 3 then
      case when new.boolean_value is null then select 'null' into v_value; else select quote_literal(new.boolean_value) into v_value; end case;
      v_value = v_value || '::boolean';
    end if;

    for v_record in select id
                    from flow.project
                    where contact_id = new.contact_id
      loop
        v_sql = $$update brs.project_details set $$ || v_field_to_update || $$ = $$ || v_value || $$
           where project_id = $$ || v_record.id;
        -- raise notice 'in if %',v_sql;
        execute v_sql;
      end loop;


  end if;

  if (TG_OP = 'UPDATE') THEN

      select count(1)
      into v_count
      from flow.user_position up
      inner join flow.white_listed_position wlp on wlp.position_id = up.position_id and wlp.archived is false
      where up.user_id = new.modified_by_id and
            up.end_date is null and wlp.custom_field_group_assignment_id = 395;
      if new.custom_field_group_assignment_id = 395 and old.int_value != new.int_value and v_count < 1 then
        raise exception 'You do not have rights to update the Lead Source for this Contact. (B)';
      end if;
    end if;

  RETURN NULL;
END
$body$
  LANGUAGE plpgsql;

drop trigger if exists update_contact_details_project_details_trg on flow.contact_custom_field_value;
CREATE TRIGGER update_contact_details_project_details_trg
  after INSERT or update
  ON flow.contact_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.update_contact_details_project_details();



-- CREATE OR REPLACE FUNCTION flow.update_project_process_step_custom_value()
--     RETURNS TRIGGER AS
-- $body$
--
-- declare
--     v_record record;
--     v_sql    text;
--     v_found  bigint;
--     v_count  integer = 0;
-- BEGIN
--
--     select count(1)
--     into v_found
--     from flow.project_process_step
--     where process_step_id = new.process_step_id
--       and project_id = new.project_id
--       and id != new.id
--       and main is false
--       and new.main is true;
--
--     if old.main is false and new.main is true or v_found > 0 then
--         v_sql = 'update brs.project_details set ';
--         for v_record in
--             select pdc.field_to_update, pdc.second_field_to_update
--             from flow.custom_field_group_assignment cfga
--                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
--                      inner join flow.custom_field cf on cf.id = cfga.custom_field_id
--                      inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
--                      inner join flow.data_type dt on dt.id = cdt.data_type_id
--                      inner join brs.project_details_config pdc on pdc.custom_field_group_assignment_id = cfga.id
--             where cfg.process_step_id = new.process_step_id
--               and cf.archived is false
--               and cfg.archived is false
--               and cfga.archived is false
--               and cf.parent_custom_field_id not in (10283, 10248,
--                                                 10057, 10118,
--                                                 10243, 10242)
--             loop
--                 v_count = v_count + 1;
--                 if v_record.second_field_to_update is not null then
--                     if not v_record.second_field_to_update = any (string_to_array(v_sql, ' ')) then
--                         v_sql = v_sql || v_record.second_field_to_update || ' = null , ';
--                     end if;
--                 end if;
--                 if not v_record.field_to_update = any (string_to_array(v_sql, ' ')) then
--                     v_sql = v_sql || v_record.field_to_update || ' = null , ';
--                 end if;
--             end loop;
--         v_sql = trim(trailing ' ,' from v_sql);
--         v_sql = v_sql || ' where project_id = ' || new.project_id || ';';
--         if v_count > 0 then
--             -- raise notice 'v_sql%',v_sql;
--             execute v_sql;
--         end if;
--     end if;
--
--     update flow.project_process_step_custom_field_value
--     set id = id
--     where project_process_step_id = new.id;
--     RETURN NULL;
-- END
-- $body$
--     LANGUAGE plpgsql;
--
-- drop trigger if exists update_project_process_step_custom_value_trg on flow.project_process_step;
-- CREATE TRIGGER update_project_process_step_custom_value_trg
--     after INSERT or update
--     ON flow.project_process_step
--     FOR EACH ROW
-- EXECUTE PROCEDURE flow.update_project_process_step_custom_value();
