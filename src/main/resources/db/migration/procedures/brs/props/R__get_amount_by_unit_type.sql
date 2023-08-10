DROP FUNCTION IF EXISTS brs.get_equipment_amount_by_type(p_system_size numeric, p_object_code varchar);
DROP FUNCTION IF EXISTS brs.get_equipment_amount_by_type(p_system_size numeric, p_object_code varchar, p_state_id bigint);
DROP FUNCTION IF EXISTS brs.get_equipment_amount_by_type(p_system_size numeric, p_object_code varchar,
                                                         p_adder_amount numeric, p_unit_type_type_id bigint,
                                                         p_states bigint[], p_state_id bigint);
drop function if exists brs.get_amount_by_unit_type(p_system_size numeric, p_object_code varchar,
                                                            p_adder_amount numeric, p_unit_type_type_id bigint,
                                                            p_total_cost numeric,
                                                            p_states bigint[],
                                                            p_state_id bigint );
CREATE OR REPLACE FUNCTION brs.get_amount_by_unit_type(p_system_size numeric, p_object_code varchar,
                                                            p_adder_amount numeric, p_unit_type_type_id bigint,
                                                            p_total_cost numeric,
                                                            p_states bigint[] default null,
                                                            p_state_id bigint default null) returns numeric
AS
$BODY$
declare
  v_amount numeric;
BEGIN

  if ((p_object_code = 'PROPOSAL_PANEL_DETAIL' and p_states is not null and
       p_state_id is not null and
       p_state_id = any (p_states)) or (p_states is null)) then

    if p_unit_type_type_id = 459 then
      v_amount = p_adder_amount;
    elsif p_unit_type_type_id = 460 then
      v_amount = p_adder_amount * p_system_size * 1000;
    elsif p_unit_type_type_id = 458 then
      v_amount = (coalesce(p_total_cost, 0)) * coalesce(p_adder_amount, 0);
    end if;
  end if;

  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
