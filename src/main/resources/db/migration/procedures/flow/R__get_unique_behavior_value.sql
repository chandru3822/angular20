CREATE OR REPLACE FUNCTION flow.get_unique_behavior_value(p_unique_behavior_type text, p_value int,
                                                          p_process_step_event_id integer default 0)
  RETURNS text AS
$BODY$
DECLARE
  v_value text;
BEGIN
  if p_unique_behavior_type = 'EVENT_RESOURCE_TRIGGER' then

    select flow.get_system_list_option_value(cf.company_system_list_id, p_value)
    into v_value
    from flow.process_step_event pse
           inner join flow.event e on pse.event_id = e.id
           inner join flow.custom_field cf on e.resource_custom_field_id = cf.id
    where pse.id = p_process_step_event_id;

  elsif p_unique_behavior_type = 'STATE_FIELD_TRIGGER' then
    select s.state
    into v_value
    from flow.company_state cs
           inner join flow.state s on cs.state_id = s.id
    where cs.id = p_value;

  elsif p_unique_behavior_type = 'COUNTRY_FIELD_TRIGGER' then
    select c.country
    into v_value
    from flow.company_country cc
           inner join flow.country c on cc.country_id = c.id
    where cc.id = p_value;
  elsif p_unique_behavior_type = 'STATE_ABBREV_FIELD_TRIGGER' then
    select s.abbreviation
    into v_value
    from flow.company_state cs
           inner join flow.state s on cs.state_id = s.id
    where cs.id = p_value;

  elsif p_unique_behavior_type = 'USER_POSITION_ID_TRIGGER' then
    select first_name || ' ' || last_name
    into v_value
    from flow.user_position up
           inner join flow.user u on up.user_id = u.id
    where up.id = p_value;

  elsif p_unique_behavior_type = 'CONTACT_TYPE_TRIGGER' then
    select ct.contact_type
    into v_value
    from flow.contact_type ct
    where ct.id = p_value;

  elsif p_unique_behavior_type = 'PROJECT_STATUS_TRIGGER' then
    select cpst.project_status_type
    into v_value
    from flow.company_project_status_type cpst
    where id = p_value;

  elsif p_unique_behavior_type = 'PROCESS_FIELD_TRIGGER' then
    select p.process_name
    into v_value
    from flow.company_process cp
           inner join flow.process p on cp.process_id = p.id
    where cp.id = p_value;

  elsif p_unique_behavior_type = 'USER_ID_TRIGGER' then
    select u.first_name||' '||u.last_name
    into v_value
    from flow.user u
    where u.id = p_value;

  end if;
  return v_value;
END ;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;



