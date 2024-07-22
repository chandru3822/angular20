drop function if exists brs.get_misc_adder_amount(p_system_size numeric, p_adders bigint[]);
drop function if exists brs.get_misc_adder_amount(p_system_size numeric, p_adders bigint[],p_rete_incentive_applied boolean);
CREATE OR REPLACE FUNCTION brs.get_misc_adder_amount(p_version_id bigint,p_system_size numeric, p_adders bigint[],p_rete_incentive_applied boolean) returns numeric
AS
$BODY$
declare
  v_amount       numeric = 0;
  x              record;
BEGIN

  for x in
    select unit_type_id,
           adder_amount,
           default_value,
           adder_id,
           rete_incentive
    from brs.get_proposal_misc_adders(p_version_id)

  loop
    if x.adder_id && p_adders or (x.default_value is not null and x.default_value is true) or (p_rete_incentive_applied is true and x.rete_incentive = 'RETE Adder') then
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

