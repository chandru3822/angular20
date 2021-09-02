CREATE OR REPLACE function flow.migrate_group_to_event(p_custom_field_group_id integer, p_event_type_id integer,p_group_order integer)
  returns void as
$$
BEGIN


  with update_data as (
    select cfg.id,
           cfg.group_name,
           (select cot.id
            from flow.company_object_type cot
                   inner join flow.object_type ot on cot.object_type_id = ot.id
            where cot.company_id = 3
              and ot.object_type = 'Event') company_object_type_id,
           p_event_type_id                  event_id
    from flow.custom_field_group cfg
           inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
           inner join flow.object_type ot on cot.object_type_id = ot.id
    where cfg.id = p_custom_field_group_id
      and cot.company_id = 3)
  update flow.custom_field_group cfg3
  set company_object_type_id = ud.company_object_type_id,
      event_id               = ud.event_id,
      process_step_id        = null,
      group_order            = p_group_order
  from update_data ud
  where ud.id = cfg3.id;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

