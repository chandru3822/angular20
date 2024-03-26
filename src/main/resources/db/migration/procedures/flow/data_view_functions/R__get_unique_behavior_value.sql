drop function if exists flow.get_unique_behavior_value(p_unique_behavior_code text, p_value text,
                                                       p_project_id bigint,
                                                       p_id bigint,
                                                       p_type varchar);
CREATE OR REPLACE FUNCTION flow.get_unique_behavior_value(p_unique_behavior_code text, p_value text,
                                                          p_project_id bigint,
                                                          p_id bigint default 0::bigint,
                                                          p_type varchar default null)
  RETURNS text AS
$BODY$
DECLARE
  v_value              text;
  v_commission_plan_id bigint;
  v_override_plan_id   bigint;
  v_ppscfv_fdc_id      bigint;
  v_ppscfv_booking_id  bigint;
  v_is_booking boolean;
BEGIN
  if p_unique_behavior_code in ('COMMISSION_EARNED_M1_TRIGGER', 'COMMISSION_EARNED_M2_TRIGGER') then

    if p_project_id is not null then
      select id,is_booking
      into v_commission_plan_id,v_is_booking
      from brs.project_commission pc
      where pc.project_id = p_project_id;

      select v.id
      into v_ppscfv_fdc_id
      from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value v
                        on v.project_process_step_id = pps.id and v.custom_field_group_assignment_id = 1251
      where pps.project_id = p_project_id
        and pps.process_step_id = 175
        and v.date_value is not null;

      if v_ppscfv_fdc_id is null then
        select v.id
        into v_ppscfv_booking_id
        from flow.project_process_step pps
               inner join flow.project_process_step_custom_field_value v
                          on v.project_process_step_id = pps.id and v.custom_field_group_assignment_id in (11,25361)
        where pps.project_id = p_project_id
          and pps.process_step_id in (4,3617)
          and v.date_value is not null;
      end if;

      if v_is_booking is true then
        delete from brs.project_commission pc2
        where pc2.project_id = p_project_id;
        v_commission_plan_id = null;
      end if;

      if v_commission_plan_id is null and (v_ppscfv_fdc_id is not null or v_ppscfv_booking_id is not null) then
        perform from brs.insert_commissions_on_project(p_project_id);
      end if;

      if (v_ppscfv_fdc_id is not null or v_ppscfv_booking_id is not null) then
        if p_unique_behavior_code = 'COMMISSION_EARNED_M1_TRIGGER' then
          select *
          into v_value
          from brs.get_commissions_earned(p_project_id, 'M1',case when v_ppscfv_fdc_id is null and v_ppscfv_booking_id is not null then true else false end );
        else
          select *
          into v_value
          from brs.get_commissions_earned(p_project_id, 'M2');
        end if;
      end if;
    end if;

  elsif p_unique_behavior_code in ('OVERRIDES_EARNED_M1_TRIGGER', 'OVERRIDES_EARNED_M2_TRIGGER') then

    if p_project_id is not null then
      select id
      into v_override_plan_id
      from brs.project_override po
      where po.project_id = p_project_id;

      select v.id
      into v_ppscfv_fdc_id
      from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value v
                        on v.project_process_step_id = pps.id and v.custom_field_group_assignment_id = 1251
      where pps.project_id = p_project_id
        and pps.process_step_id = 175
        and v.date_value is not null;

      if v_override_plan_id is null and v_ppscfv_fdc_id is not null then
        perform from brs.insert_commissions_on_project(p_project_id);
      end if;

      if v_ppscfv_fdc_id is not null then
        if p_unique_behavior_code = 'OVERRIDES_EARNED_M1_TRIGGER' then
          select *
          into v_value
          from brs.get_overrides_earned(p_project_id, 'M1');
        else
          select *
          into v_value
          from brs.get_overrides_earned(p_project_id, 'M2');
        end if;
      end if;
    end if;
  elsif p_unique_behavior_code = 'TOTAL_COMMISSIONS_TRIGGER' then

    if p_project_id is not null then

      select id,is_booking
      into v_commission_plan_id,v_is_booking
      from brs.project_commission pc
      where pc.project_id = p_project_id;

      select v.id
      into v_ppscfv_fdc_id
      from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value v
                        on v.project_process_step_id = pps.id and v.custom_field_group_assignment_id = 1251
      where pps.project_id = p_project_id
        and pps.process_step_id = 175
        and v.date_value is not null;

      if v_ppscfv_fdc_id is null then
        select v.id
        into v_ppscfv_booking_id
        from flow.project_process_step pps
               inner join flow.project_process_step_custom_field_value v
                          on v.project_process_step_id = pps.id and v.custom_field_group_assignment_id in (11,25361)
        where pps.project_id = p_project_id
          and pps.process_step_id in (4,3617)
          and v.date_value is not null;
      end if;

      if v_is_booking is true then
        delete from brs.project_commission pc2
        where pc2.project_id = p_project_id;
        v_commission_plan_id = null;
      end if;

      if (v_commission_plan_id is null) and (v_ppscfv_fdc_id is not null or v_ppscfv_booking_id is not null) then
        perform from brs.insert_commissions_on_project(p_project_id);
      end if;

      select *
      into v_value
      from brs.get_total_commissions_amount(p_project_id,case when v_ppscfv_fdc_id is null and v_ppscfv_booking_id is not null then true else false end );
    end if;

  elsif p_unique_behavior_code = 'TOTAL_OVERRIDES_TRIGGER' then

    if p_project_id is not null then
      select id
      into v_override_plan_id
      from brs.project_override po
      where po.project_id = p_project_id;


      select v.id
      into v_ppscfv_fdc_id
      from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value v
                        on v.project_process_step_id = pps.id and v.custom_field_group_assignment_id = 1251
      where pps.project_id = p_project_id
        and pps.process_step_id = 175
        and v.date_value is not null;

      if (v_override_plan_id is null) and v_ppscfv_fdc_id is not null then
        perform from brs.insert_commissions_on_project(p_project_id);
      end if;
      select *
      into v_value
      from brs.get_total_overrides_amount(p_project_id);
    end if;

  elsif p_value is null then
    v_value = null;
  elsif p_unique_behavior_code = 'EVENT_RESOURCE_TRIGGER' then

    select t.name
    into v_value
    from flow.project_process_step_event ppse
           inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
           inner join flow.event e on pse.event_id = e.id
           inner join flow.custom_field cf on e.resource_custom_field_id = cf.id
           inner join lateral (select *
                               from flow.get_system_list_option_value(cf.company_system_list_id, p_value::bigint)) t
                      on true
    where ppse.id = p_id;

  elsif p_unique_behavior_code = 'STATE_FIELD_TRIGGER' then
    select s.state
    into v_value
    from flow.company_state cs
           inner join flow.state s on cs.state_id = s.id
    where cs.id = p_value::bigint;
  elsif p_unique_behavior_code = 'CLOSER_EMPLOYEE_BY_ID_TRIGGER' then
    select ucfv.text_value
    into v_value
    from flow.user_position up
      inner join flow.user u on up.user_id = u.id
      inner join flow.user_custom_field_value ucfv on ucfv.user_id = u.id and ucfv.custom_field_group_assignment_id =19176
    where up.id = p_value::bigint;

  elsif p_unique_behavior_code = 'STATE_FIELD_ID_TRIGGER' then
    select s.id
    into v_value
    from flow.company_state cs
           inner join flow.state s on cs.state_id = s.id
    where cs.id = p_value::bigint;

  elsif p_unique_behavior_code = 'COUNTRY_FIELD_TRIGGER' then
    select c.country
    into v_value
    from flow.company_country cc
           inner join flow.country c on cc.country_id = c.id
    where cc.id = p_value::bigint;
  elsif p_unique_behavior_code = 'STATE_ABBREV_FIELD_TRIGGER' then
    select s.abbreviation
    into v_value
    from flow.company_state cs
           inner join flow.state s on cs.state_id = s.id
    where cs.id = p_value::bigint;
  elsif p_unique_behavior_code = 'PROCESS_STEP_NAME_TRIGGER' then
    select ps.process_step_name
    into v_value
    from flow.process_step ps
    where ps.id = p_value::bigint;

  elsif p_unique_behavior_code = 'EVENT_PROCESS_STEP_TRIGGER' then
    select ps.process_step_name
    into v_value
    from flow.process_step_event pse
           inner join flow.process_step ps on pse.process_step_id = ps.id
    where pse.id = p_value::bigint;

  elsif p_unique_behavior_code = 'CONVERT_TIMESTAMP_TO_DATE_TRIGGER' then
    if p_value is null then
      select 'null' into v_value;
    else
      select ((p_value::timestamp at time zone 'UTC') at time zone 'US/Mountain')::date
      into v_value;
    end if;

  elsif p_unique_behavior_code = 'EVENT_TRIGGER' then
    select e.event_name
    into v_value
    from flow.process_step_event pse
           inner join flow.event e on pse.event_id = e.id
    where pse.id = p_value::bigint;

  elsif p_unique_behavior_code = 'EVENT_STATUS_TRIGGER' then
    select cest.event_status_type
    into v_value
    from flow.company_event_status_type cest
    where cest.id = p_value::bigint;

  elsif p_unique_behavior_code = 'PROCESS_STEP_STATUS_TRIGGER' then
    select cpsst.process_step_status_type
    into v_value
    from flow.company_process_step_status_type cpsst
    where cpsst.id = p_value::bigint;

  elsif p_unique_behavior_code = 'USER_POSITION_NAME_BY_ID_TRIGGER' then
    select concat(first_name, ' ', last_name)
    into v_value
    from flow.user_position up
           inner join flow.user u on up.user_id = u.id
    where up.id = p_value::bigint;

  elsif p_unique_behavior_code = 'USER_POSITION_ID_TRIGGER' then
    select u.id
    into v_value
    from flow.user_position up
           inner join flow.user u on up.user_id = u.id
    where up.id = p_value::bigint;

  elsif p_unique_behavior_code = 'USER_POSITION_ORG_ID_TRIGGER' then
    select up.org_id
    into v_value
    from flow.user_position up
           inner join flow.user u on up.user_id = u.id
    where up.id = p_value::bigint and up.primary_flag is true;

  elsif p_unique_behavior_code = 'CONTACT_TYPE_TRIGGER' then
    select ct.contact_type
    into v_value
    from flow.contact_type ct
    where ct.id = p_value::bigint;

  elsif p_unique_behavior_code = 'PROJECT_STATUS_TRIGGER' then
    select cpst.project_status_type
    into v_value
    from flow.company_project_status_type cpst
    where id = p_value::bigint;

  elsif p_unique_behavior_code = 'PROCESS_FIELD_TRIGGER' then
    select p.process_name
    into v_value
    from flow.company_process cp
           inner join flow.process p on cp.process_id = p.id
    where cp.id = p_value::bigint;

  elsif p_unique_behavior_code = 'USER_NAME_BY_ID_TRIGGER' then
    select concat(u.first_name, ' ', u.last_name)
    into v_value
    from flow.user u
    where u.id = p_value::bigint;

  elsif p_unique_behavior_code = 'USER_ID_TRIGGER' then
    select id
    into v_value
    from flow.user u
    where u.id = p_value::bigint;

  elsif p_unique_behavior_code = 'CONTACT_NAME_BY_ID_TRIGGER' then
    select concat(c.first_name, ' ', c.last_name)
    into v_value
    from flow.contact c
    where c.id = p_value::bigint;

  elsif p_unique_behavior_code = 'LIST_OF_VALUE_INT_ARRAY_TRIGGER' then
    raise notice 'I got here %',p_value;
    select string_agg(lov.name, ', ')
    into v_value
    from flow.list_of_value lov
    where lov.id = any (p_value::bigint[]);

  elsif p_unique_behavior_code = 'DEFAULT_CFGA_TRIGGER' or
        p_unique_behavior_code = 'DEFAULT_CFGA_TRIGGER_BIGINT' then

    if p_type = 'PROCESS_STEP' then

      select flow.get_secondary_detail_value(cf.list_of_value_id,
                                             cf.company_system_list_id,
                                             p_value::bigint,
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
                                             p_value::bigint,
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
                                             p_value::bigint,
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
                                             p_value::bigint,
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
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;



