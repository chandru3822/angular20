drop function if exists brs.get_misc_adder_amount(p_system_size numeric);
CREATE OR REPLACE FUNCTION brs.get_misc_adder_amount(p_system_size numeric) returns numeric
AS
$BODY$
declare
  v_unit_type_id bigint;
  v_amount       numeric;
  v_adder_amount numeric;
  x              record;
BEGIN

  for x in
    select proposal_group_uuid
    from proposal_value
    where field_id = 126
    loop
      select int_value
      into v_unit_type_id
      from proposal_value pv
      where pv.proposal_group_uuid = x.proposal_group_uuid
        and pv.field_id = 97;

      select value::numeric
      into v_adder_amount
      from proposal_value pv
      where pv.proposal_group_uuid = x.proposal_group_uuid
        and pv.field_id = 119;

      if v_unit_type_id = 459 then
        v_amount = coalesce(v_amount, 0) + v_adder_amount;
      elsif v_unit_type_id = 460 then
        v_amount = coalesce(v_amount, 0) + v_adder_amount * p_system_size * 1000;
      elsif v_unit_type_id = 458 then
        --percent of total  total_system_cost*rebate_amount
      end if;
    end loop;

  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;

