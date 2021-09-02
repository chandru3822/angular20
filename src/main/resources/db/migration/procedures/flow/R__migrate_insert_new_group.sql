CREATE OR REPLACE function flow.migrate_insert_new_group(p_group_name varchar,
                                                         p_group_order integer,
                                                         p_process_step_id integer,
                                                         p_event_type_id integer)
  returns void as
$$
declare
  v_company_object_type_id integer;
BEGIN

  if p_event_type_id is not null then
    select cot.id
    into v_company_object_type_id
    from flow.company_object_type cot
           inner join flow.object_type ot on cot.object_type_id = ot.id
    where cot.company_id = 3
      and ot.object_code = 'EVENT';
  else
    select cot.id
    into v_company_object_type_id
    from flow.company_object_type cot
           inner join flow.object_type ot on cot.object_type_id = ot.id
    where cot.company_id = 3
      and ot.object_code = 'PROCESS_STEP';
  end if;

  insert into flow.custom_field_group(group_name, company_object_type_id, group_order,
                                      process_step_id, event_id, date_created,
                                      created_by_id)
  values (p_group_name,v_company_object_type_id,p_group_order,p_process_step_id,p_event_type_id,now(),2350555);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

