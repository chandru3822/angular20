CREATE OR REPLACE FUNCTION flow.get_unique_behavior_value(p_unique_behavior_type text, p_value text,
                                                          p_id integer default 0,
                                                          p_type varchar default null)
  RETURNS text AS
$BODY$
DECLARE
  v_value text;
BEGIN

  if p_value is null then
    v_value = null;
  elsif p_unique_behavior_type = 'EVENT_RESOURCE_TRIGGER' then

    select flow.get_system_list_option_value(cf.company_system_list_id, p_value::integer)
    into v_value
    from flow.project_process_step_event ppse
           inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
           inner join flow.event e on pse.event_id = e.id
           inner join flow.custom_field cf on e.resource_custom_field_id = cf.id
    where ppse.id = p_id;

  elsif p_unique_behavior_type = 'STATE_FIELD_TRIGGER' then
    select s.state
    into v_value
    from flow.company_state cs
           inner join flow.state s on cs.state_id = s.id
    where cs.id = p_value::integer;

  elsif p_unique_behavior_type = 'COUNTRY_FIELD_TRIGGER' then
    select c.country
    into v_value
    from flow.company_country cc
           inner join flow.country c on cc.country_id = c.id
    where cc.id = p_value::integer;
  elsif p_unique_behavior_type = 'STATE_ABBREV_FIELD_TRIGGER' then
    select s.abbreviation
    into v_value
    from flow.company_state cs
           inner join flow.state s on cs.state_id = s.id
    where cs.id = p_value::integer;
  elsif p_unique_behavior_type = 'PROCESS_STEP_NAME_TRIGGER' then
    select ps.process_step_name
    into v_value
    from flow.process_step ps
    where ps.id = p_value::integer;

  elsif p_unique_behavior_type = 'EVENT_PROCESS_STEP_TRIGGER' then
    select ps.process_step_name
    into v_value
    from flow.process_step_event pse
        inner join flow.process_step ps on pse.process_step_id = ps.id
    where pse.id = p_value::integer;

  elsif p_unique_behavior_type = 'CONVERT_TIMESTAMP_TO_DATE_TRIGGER' then
    if p_value is null then
      select 'null' into v_value;
    else
      select ((p_value::timestamp at time zone 'UTC') at time zone  'US/Mountain')::date
      into v_value;
    end if;

  elsif p_unique_behavior_type = 'EVENT_TRIGGER' then
    select e.event_name
    into v_value
    from flow.process_step_event pse
           inner join flow.event e on pse.event_id = e.id
    where pse.id = p_value::integer;

  elsif p_unique_behavior_type = 'EVENT_STATUS_TRIGGER' then
    select cest.event_status_type
    into v_value
    from flow.company_event_status_type cest
    where cest.id = p_value::integer;

  elsif p_unique_behavior_type = 'PROCESS_STEP_STATUS_TRIGGER' then
    select cpsst.process_step_status_type
    into v_value
    from flow.company_process_step_status_type cpsst
    where cpsst.id = p_value::integer;

  elsif p_unique_behavior_type = 'USER_POSITION_NAME_BY_ID_TRIGGER' then
    select concat(first_name, ' ', last_name)
    into v_value
    from flow.user_position up
           inner join flow.user u on up.user_id = u.id
    where up.id = p_value::integer;

  elsif p_unique_behavior_type = 'USER_POSITION_ID_TRIGGER' then
    select u.id
    into v_value
    from flow.user_position up
           inner join flow.user u on up.user_id = u.id
    where up.id = p_value::integer;

  elsif p_unique_behavior_type = 'CONTACT_TYPE_TRIGGER' then
    select ct.contact_type
    into v_value
    from flow.contact_type ct
    where ct.id = p_value::integer;

  elsif p_unique_behavior_type = 'PROJECT_STATUS_TRIGGER' then
    select cpst.project_status_type
    into v_value
    from flow.company_project_status_type cpst
    where id = p_value::integer;

  elsif p_unique_behavior_type = 'PROCESS_FIELD_TRIGGER' then
    select p.process_name
    into v_value
    from flow.company_process cp
           inner join flow.process p on cp.process_id = p.id
    where cp.id = p_value::integer;

  elsif p_unique_behavior_type = 'USER_NAME_BY_ID_TRIGGER' then
    select concat(u.first_name, ' ', u.last_name)
    into v_value
    from flow.user u
    where u.id = p_value::integer;

  elsif p_unique_behavior_type = 'USER_ID_TRIGGER' then
    select id
    into v_value
    from flow.user u
    where u.id = p_value::integer;

  elsif p_unique_behavior_type = 'CONTACT_NAME_BY_ID_TRIGGER' then
    select concat(c.first_name, ' ', c.last_name)
    into v_value
    from flow.contact c
    where c.id = p_value::integer;

  elsif p_unique_behavior_type = 'DEFAULT_CFGA_TRIGGER' then

    if p_type = 'PROCESS_STEP' then

      select flow.get_secondary_detail_value(cf.list_of_value_id,
                                             cf.company_system_list_id,
                                             p_value::integer,
                                             cf.custom_field_sql_column,
                                             cf.custom_field_sql_reference_table)
      into v_value
      from flow.project_process_step_custom_field_value ppscfv
             inner join flow.custom_field_group_assignment cfga on ppscfv.custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field cf on cf.id = cfga.custom_field_id
      where ppscfv.id = p_id;
    end if;
    if v_value is null and p_type = 'EVENT' then
      select flow.get_secondary_detail_value(cf.list_of_value_id,
                                             cf.company_system_list_id,
                                             p_value::integer,
                                             cf.custom_field_sql_column,
                                             cf.custom_field_sql_reference_table)
      into v_value
      from flow.project_process_step_event_custom_field_value ppscfv
             inner join flow.custom_field_group_assignment cfga on ppscfv.custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field cf on cf.id = cfga.custom_field_id
      where ppscfv.id = p_id;
    end if;
    if v_value is null and p_type = 'PROJECT' then
      select flow.get_secondary_detail_value(cf.list_of_value_id,
                                             cf.company_system_list_id,
                                             p_value::integer,
                                             cf.custom_field_sql_column,
                                             cf.custom_field_sql_reference_table)
      into v_value
      from flow.project_custom_field_value ppscfv
             inner join flow.custom_field_group_assignment cfga on ppscfv.custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field cf on cf.id = cfga.custom_field_id
      where ppscfv.id = p_id;
    end if;

    if v_value is null and p_type = 'CONTACT' then
      select flow.get_secondary_detail_value(cf.list_of_value_id,
                                             cf.company_system_list_id,
                                             p_value::integer,
                                             cf.custom_field_sql_column,
                                             cf.custom_field_sql_reference_table)
      into v_value
      from flow.contact_custom_field_value ppscfv
             inner join flow.custom_field_group_assignment cfga on ppscfv.custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field cf on cf.id = cfga.custom_field_id
      where ppscfv.id = p_id;
    end if;


  end if;
  return v_value;
END ;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;



