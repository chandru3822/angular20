CREATE OR REPLACE FUNCTION flow.exact_field_value_compare(p_project_id integer, p_pps_id integer, p_ppse_id integer,
                                                          p_cfga_id_1 integer, p_cfga_id_2 integer)
                                                          --at first i needed p_pps_id, now i dont but i left it in so that if we ever need it we have it....jk, it was just more work to take it out than it was to leave it
  returns boolean AS
$BODY$
declare
  v_cfga_1_value          text;
  v_cfga_2_value          text;
  v_cfga_1_company_id     int;
  v_cfga_2_company_id     int;
BEGIN

  --verify that both cfga ids come from the same company (which also ensures they are valid cfga ids)
  select cf.company_id
  into v_cfga_1_company_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
  where cfga.id = p_cfga_id_1;

  select cf.company_id
  into v_cfga_2_company_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
  where cfga.id = p_cfga_id_2;

  --only continue if both company ids are the same
  if (v_cfga_1_company_id = v_cfga_2_company_id) then
    select * into v_cfga_1_value
    from flow.get_cfv_value_as_text(p_project_id::int, p_ppse_id::int, p_cfga_id_1);

    select * into v_cfga_2_value
    from flow.get_cfv_value_as_text(p_project_id::int, p_ppse_id::int, p_cfga_id_2);

  end if;

  if (v_cfga_1_value = v_cfga_2_value or (v_cfga_1_value is null and v_cfga_2_value is null))
  then
    return true;
  else
    return false;
  end if;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
