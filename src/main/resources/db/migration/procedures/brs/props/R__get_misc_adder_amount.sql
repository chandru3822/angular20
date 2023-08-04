drop function if exists brs.get_misc_adder_amount(p_system_size numeric, p_adders bigint[]);
CREATE OR REPLACE FUNCTION brs.get_misc_adder_amount1(p_system_size numeric, p_adders bigint[]) returns numeric
AS
$BODY$
declare
  v_amount       numeric = 0;
  x              record;
BEGIN

  for x in
    select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::integer as unit_type_id,
           (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric   as adder_amount,
  (SELECT ARRAY(SELECT jsonb_array_elements_text((jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 126)') ->>
                                                 'intArrayValue')::jsonb)))::bigint[] as adder_id

  from proposal_value
  where object_code = 'PROPOSAL_MISC_ADDERS'
  loop
    if x.adder_id && p_adders then
      if x.unit_type_id = 459 then
        v_amount = coalesce(v_amount, 0) + x.adder_amount;
      elsif x.unit_type_id = 460 then
        v_amount = coalesce(v_amount, 0) + x.adder_amount * p_system_size * 1000;
      elsif x.unit_type_id = 458 then
        --percent of total  total_system_cost*rebate_amount
      end if;
    end if;
  end loop;

  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;

