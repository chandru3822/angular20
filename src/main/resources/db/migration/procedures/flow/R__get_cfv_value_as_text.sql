-- drop function if exists flow.get_cfv_value_as_text(int, int, int, int);
CREATE OR REPLACE FUNCTION flow.get_cfv_value_as_text(p_project_id integer, p_ppse_id integer, p_cfga_id integer)
  returns text AS
$BODY$
declare
  v_cfga_object_type_id int;
  v_cfga_data_type_id   int;
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
      select case
               when v_cfga_data_type_id = 1 then date_value::text
               when v_cfga_data_type_id = 2 then timestamp_value::text
               when v_cfga_data_type_id = 3 then boolean_value::text
               when v_cfga_data_type_id = 4 then numeric_value::text
               when v_cfga_data_type_id = 5 then text_value::text
               when v_cfga_data_type_id = 6 then int_value::text
               when v_cfga_data_type_id = 7 then int_array_value::text end
      into v_cfga_value
      from flow.project_custom_field_value cfv
      where cfv.custom_field_group_assignment_id = p_cfga_id
        and cfv.project_id = p_project_id;
    elseif (v_cfga_object_type_id = 2) then
      --get the value from contact cfv
      select case
               when v_cfga_data_type_id = 1 then date_value::text
               when v_cfga_data_type_id = 2 then timestamp_value::text
               when v_cfga_data_type_id = 3 then boolean_value::text
               when v_cfga_data_type_id = 4 then numeric_value::text
               when v_cfga_data_type_id = 5 then text_value::text
               when v_cfga_data_type_id = 6 then int_value::text
               when v_cfga_data_type_id = 7 then int_array_value::text end
      into v_cfga_value
      from flow.contact_custom_field_value cfv
      where cfv.custom_field_group_assignment_id = p_cfga_id
        and cfv.contact_id = (select contact_id from flow.project p where p.id = p_project_id);
    elseif (v_cfga_object_type_id = 4) then
      --todo get value from primary for the cfga not the calling pps
      --get the value from process step cfv
      select case
               when v_cfga_data_type_id = 1 then date_value::text
               when v_cfga_data_type_id = 2 then timestamp_value::text
               when v_cfga_data_type_id = 3 then boolean_value::text
               when v_cfga_data_type_id = 4 then numeric_value::text
               when v_cfga_data_type_id = 5 then text_value::text
               when v_cfga_data_type_id = 6 then int_value::text
               when v_cfga_data_type_id = 7 then int_array_value::text end
      into v_cfga_value
      from flow.project_process_step_custom_field_value cfv
        inner join flow.project_process_step pps on cfv.project_process_step_id = pps.id and pps.main is true and pps.archived is false
      where cfv.custom_field_group_assignment_id = p_cfga_id;
    elseif (v_cfga_object_type_id = 6) then
      --get the value from event cfv
      select case
               when v_cfga_data_type_id = 1 then date_value::text
               when v_cfga_data_type_id = 2 then timestamp_value::text
               when v_cfga_data_type_id = 3 then boolean_value::text
               when v_cfga_data_type_id = 4 then numeric_value::text
               when v_cfga_data_type_id = 5 then text_value::text
               when v_cfga_data_type_id = 6 then int_value::text
               when v_cfga_data_type_id = 7 then int_array_value::text end
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
