drop function if exists brs.get_misc_adder_amount(p_system_size numeric, p_adders bigint[]);
drop function if exists brs.get_misc_adder_amount(p_system_size numeric, p_adders bigint[],p_rete_incentive_applied boolean);
drop function if exists brs.get_misc_adder_amount(bigint, numeric, bigint[], boolean);
CREATE OR REPLACE FUNCTION brs.get_misc_adder_amount(p_version_id bigint,p_system_size numeric, p_adders bigint[],p_rete_incentive_applied boolean)
  returns table (misc_adder numeric,rete_incentive_adder numeric)
AS
$BODY$
declare
  v_amount       numeric = 0;
  v_rete_amount numeric = 0;
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
        if (p_rete_incentive_applied is true and x.rete_incentive = 'RETE Adder') then
          v_rete_amount = coalesce(v_amount, 0) + x.adder_amount;
        elsif x.rete_incentive != 'RETE Adder' then
          v_amount = coalesce(v_amount, 0) + x.adder_amount;
        end if;

      elsif x.unit_type_id = 460 then
        if (p_rete_incentive_applied is true and x.rete_incentive = 'RETE Adder') then
          v_rete_amount = coalesce(v_amount, 0) + x.adder_amount * p_system_size * 1000;
        elsif x.rete_incentive != 'RETE Adder' then
          v_amount = coalesce(v_amount, 0) + x.adder_amount * p_system_size * 1000;
        end if;

      elsif x.unit_type_id = 458 then
        --percent of total  total_system_cost*rebate_amount
      end if;
    end if;
  end loop;

  return query select coalesce(v_amount, 0),coalesce(v_rete_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;

