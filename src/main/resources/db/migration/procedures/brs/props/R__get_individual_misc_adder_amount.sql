drop function if exists brs.get_individual_misc_adder_amount(p_version_id bigint, p_system_size numeric, p_adders bigint[], p_rete_incentive_applied boolean, p_panel_quantity bigint);
CREATE OR REPLACE FUNCTION brs.get_individual_misc_adder_amount(p_version_id bigint, p_system_size numeric, p_adders bigint[], p_rete_incentive_applied boolean, p_panel_quantity bigint)
	returns table(adder_name text,
                misc_adder numeric) AS
$BODY$
declare
  x              record;
BEGIN

  for x in
    select unit_type_id,
           adder_amount,
           default_value,
           adder_id,
           rete_incentive,
           adder_text
    from brs.get_proposal_misc_adders(p_version_id)

    loop
      adder_name = null;
      misc_adder = null;
      if x.adder_id && p_adders then
        if x.unit_type_id = 459 then
          if (p_rete_incentive_applied is true and x.rete_incentive = 'RETE Adder') then
            misc_adder = x.adder_amount;
          elsif x.rete_incentive is null or x.rete_incentive != 'RETE Adder' then
            misc_adder = x.adder_amount;
          end if;

        elsif x.unit_type_id = 460 then
          if (p_rete_incentive_applied is true and x.rete_incentive = 'RETE Adder') then
            misc_adder = x.adder_amount * p_system_size * 1000;
          elsif x.rete_incentive is null or x.rete_incentive != 'RETE Adder' then
            misc_adder = x.adder_amount * p_system_size * 1000;
          end if;

        elsif x.unit_type_id = 13434 then
          if (p_rete_incentive_applied is true and x.rete_incentive = 'RETE Adder') then
            misc_adder = x.adder_amount * p_panel_quantity;
          elsif x.rete_incentive is null or x.rete_incentive != 'RETE Adder' then
            misc_adder = x.adder_amount * p_panel_quantity;
          end if;
        end if;
      end if;
      adder_name = coalesce(x.rete_incentive,x.adder_text);
      RETURN NEXT;
    end loop;


END
$BODY$
	LANGUAGE plpgsql VOLATILE
	                 COST 100;
