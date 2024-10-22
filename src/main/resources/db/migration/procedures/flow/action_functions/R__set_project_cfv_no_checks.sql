drop FUNCTION if exists flow.set_project_cfv_no_checks(p_project_id bigint, p_user_id bigint, p_cfga bigint,
                                                p_value_to_save text, p_override_existing boolean,
                                                p_secondary_value_to_save text);
CREATE OR REPLACE FUNCTION flow.set_project_cfv_no_checks(p_project_id bigint, p_user_id bigint, p_cfga bigint,
                                                   p_value_to_save text, p_override_existing boolean default false,
                                                   p_secondary_value_to_save text default null)
  returns void AS
$BODY$
declare
  v_data_type_id       bigint;
BEGIN

  select cdt.data_type_id
  into v_data_type_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
  where cfga.id = p_cfga;


  -- 1,date
  -- 2,timestamp
  -- 3,boolean
  -- 4,numeric
  -- 5,text
  -- 6,bigint
  -- 7,bigint array
  -- 8,system
  -- 9,System List
  if v_data_type_id = 1 then
    insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value,
                                                timestamp_value, boolean_value, text_value, numeric_value, int_value,
                                                int_array_value, created_by_id, date_created, modified_by_id,
                                                date_modified)
    values (p_project_id, p_cfga, p_value_to_save::date, null, null, null, null,
            null, null, p_user_id, now(), p_user_id, now()) on conflict do nothing;
  elsif v_data_type_id = 2 then
    insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value,
                                                timestamp_value, boolean_value, text_value, numeric_value, int_value,
                                                int_array_value, created_by_id, date_created, modified_by_id,
                                                date_modified)
    values (p_project_id, p_cfga, null,  p_value_to_save::timestamp, null,
            null, null, null, null, p_user_id, now(), p_user_id, now()) on conflict do nothing;
  elsif v_data_type_id = 3 then
    insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value,
                                                timestamp_value, boolean_value, text_value, numeric_value, int_value,
                                                int_array_value, created_by_id, date_created, modified_by_id,
                                                date_modified)
    values (p_project_id, p_cfga, null, null, p_value_to_save::boolean, null, null, null, null, p_user_id, now(),
            p_user_id, now()) on conflict do nothing;
  elsif v_data_type_id = 4 then
    insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value,
                                                timestamp_value, boolean_value, text_value, numeric_value, int_value,
                                                int_array_value, created_by_id, date_created, modified_by_id,
                                                date_modified)
    values (p_project_id, p_cfga, null, null, null, null, p_value_to_save::numeric(10, 2), null, null, p_user_id, now(),
            p_user_id, now()) on conflict do nothing;
  elsif v_data_type_id = 5 or v_data_type_id = 13 then
    insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value,
                                                timestamp_value, boolean_value, text_value, numeric_value, int_value,
                                                int_array_value, created_by_id, date_created, modified_by_id,
                                                date_modified, rich_text_value)
    values (p_project_id, p_cfga, null, null, null, p_value_to_save::text, null, null, null, p_user_id, now(),
            p_user_id, now(),
            case when v_data_type_id = 13 then coalesce(p_secondary_value_to_save, p_value_to_save)::text end) on conflict do nothing;
  elsif v_data_type_id = 6 or v_data_type_id = 9
    or v_data_type_id =
       8 -- note: data type id 8 = system. for now these are always single select lists.  this will break if that changes
  then
    insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value,
                                                timestamp_value, boolean_value, text_value, numeric_value, int_value,
                                                int_array_value, created_by_id, date_created, modified_by_id,
                                                date_modified)
    values (p_project_id, p_cfga, null, null, null, null, null, p_value_to_save::bigint, null, p_user_id, now(),
            p_user_id, now()) on conflict do nothing;
  elsif v_data_type_id = 7 then
    insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value,
                                                timestamp_value, boolean_value, text_value, numeric_value, int_value,
                                                int_array_value, created_by_id, date_created, modified_by_id,
                                                date_modified)
    values (p_project_id, p_cfga, null, null, null, null, null, null, p_value_to_save::bigint[], p_user_id, now(),
            p_user_id, now()) on conflict do nothing;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
