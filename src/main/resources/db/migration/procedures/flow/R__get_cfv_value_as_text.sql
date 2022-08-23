-- drop function if exists flow.get_cfv_value_as_text(bigint, bigint, bigint, bigint);
drop function if exists flow.get_cfv_value_as_text(p_project_id bigint, p_ppse_id bigint, p_cfga_id bigint);
  CREATE OR REPLACE FUNCTION flow.get_cfv_value_as_text(p_project_id bigint, p_ppse_id bigint, p_cfga_id bigint)
  returns text AS
$BODY$
declare
  v_cfga_object_type_id bigint;
  v_cfga_data_type_id   bigint;
  v_cfga_value          text;
BEGIN
  --verify that both cfga ids come from the same company (which also ensures they are valid cfga ids)
  select cot.object_type_id, cdt.data_type_id
  into v_cfga_object_type_id, v_cfga_data_type_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
  where cfga.id = p_cfga_id;

  --only continue if both company ids are the same
    if (v_cfga_object_type_id = 1) then
      --get the value from project cfv
      select coalesce(text_value,
                      boolean_value::text,
                      date_value::text,
                      timestamp_value::text,
                      numeric_value::text,
                      int_value::text,
                      int_array_value::text)
      into v_cfga_value
      from flow.project_custom_field_value cfv
      where cfv.custom_field_group_assignment_id = p_cfga_id
        and cfv.project_id = p_project_id;
    elseif (v_cfga_object_type_id = 2) then
      --get the value from contact cfv
      select coalesce(text_value,
                      boolean_value::text,
                      date_value::text,
                      timestamp_value::text,
                      numeric_value::text,
                      int_value::text,
                      int_array_value::text)
      into v_cfga_value
      from flow.contact_custom_field_value cfv
      where cfv.custom_field_group_assignment_id = p_cfga_id
        and cfv.contact_id = (select contact_id from flow.project p where p.id = p_project_id);
    elseif (v_cfga_object_type_id = 4) then
      --todo get value from primary for the cfga not the calling pps
      --get the value from process step cfv
      select coalesce(text_value,
                      boolean_value::text,
                      date_value::text,
                      timestamp_value::text,
                      numeric_value::text,
                      int_value::text,
                      int_array_value::text)
      into v_cfga_value
      from flow.project_process_step_custom_field_value cfv
        inner join flow.project_process_step pps on cfv.project_process_step_id = pps.id and pps.main is true and pps.archived is false
        inner join flow.project p on pps.project_id = p.id and p.id = p_project_id
      where cfv.custom_field_group_assignment_id = p_cfga_id;
    elseif (v_cfga_object_type_id = 6) then
      --get the value from event cfv
      select coalesce(text_value,
                      boolean_value::text,
                      date_value::text,
                      timestamp_value::text,
                      numeric_value::text,
                      int_value::text,
                      int_array_value::text)
      into v_cfga_value
      from flow.project_process_step_event_custom_field_value cfv
      where cfv.custom_field_group_assignment_id = p_cfga_id
        and cfv.project_process_step_event_id = p_ppse_id;
    end if;

  return v_cfga_value;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
