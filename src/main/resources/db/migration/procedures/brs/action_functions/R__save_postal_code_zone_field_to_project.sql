-- drop FUNCTION if exists brs.save_postal_code_zone_field_to_project(bigint, bigint, bigint, int, boolean);
CREATE OR REPLACE FUNCTION brs.save_postal_code_zone_field_to_project(p_project_id bigint, p_ppse_id bigint, p_current_user_id bigint, p_field_to_save int, p_overwrite_existing boolean)
  RETURNS void
  LANGUAGE plpgsql
AS
$function$
declare
  v_metro_area_id int;
  v_adder_amount int;
BEGIN
  -- we dont need the ppse_id yet but it is easier to add now vs later if we need it so i put it in

  -- p_field_to_save, 1 = metro area, 2 = adder amount ...more later?

  select pcz.adder_amount, pcz.metro_area_id
  into v_adder_amount, v_metro_area_id
  from flow.postal_code pc
         inner join flow.postal_code_zone pcz on pcz.id = pc.postal_code_zone_id
  where pc.archived is false
    and trim(pc.postal_code) = (select left(p.postal_code, 5)
                                from flow.project p
                                where p.id = p_project_id);

  if p_field_to_save = 1 then
    --update the metro area
    perform flow.set_project_cfv(p_project_id, p_current_user_id, 1051::bigint, v_metro_area_id::text, p_overwrite_existing::boolean);
  elsif p_field_to_save = 2 then
    --update the adder amount
    perform flow.set_pps_cfv(p_project_id, p_current_user_id, 26217::bigint, v_adder_amount::text, p_overwrite_existing::boolean);
  end if;

END;
$function$
