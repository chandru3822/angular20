DROP FUNCTION IF EXISTS brs.get_equipment_amount_by_type( p_system_size numeric, p_object_code varchar);
DROP FUNCTION IF EXISTS brs.get_equipment_amount_by_type( p_system_size numeric, p_object_code varchar,p_state_id bigint);
CREATE OR REPLACE FUNCTION brs.get_equipment_amount_by_type(p_system_size numeric, p_object_code varchar,p_state_id bigint default null) returns numeric
AS
$BODY$
declare
  v_unit_type_id bigint;
  v_amount       numeric;
  v_adder_amount numeric;
BEGIN
  with equipment_type as (select *
                          from proposal_value
                          where field_id = 97
                            and object_code = p_object_code)
  select pv.int_value
  into v_unit_type_id
  from proposal_value pv
         inner join equipment_type et on et.proposal_group_uuid = pv.proposal_group_uuid
  where pv.field_id = 97 and
        case when p_object_code = 'PROPOSAL_PANEL_DETAIL' then
        exists (select * from proposal_value where object_code = 'PROPOSAL_PANEL_DETAIL' and
                                                    p_state_id = any (int_array_value))
  else 1=1 end;

  with equipment_type as (select *
                          from proposal_value
                          where field_id = 119
                            and object_code = p_object_code)
  select pv.value::numeric
  into v_adder_amount
  from proposal_value pv
         inner join equipment_type et on et.proposal_group_uuid = pv.proposal_group_uuid
  where pv.field_id = 119 and
    case when p_object_code = 'PROPOSAL_PANEL_DETAIL' then
           exists (select * from proposal_value where object_code = 'PROPOSAL_PANEL_DETAIL' and
               p_state_id = any (int_array_value))
         else 1=1 end;

  if v_unit_type_id = 459 then
    v_amount = v_adder_amount;
  elsif v_unit_type_id = 460 then
    v_amount = v_adder_amount * p_system_size * 1000;
  elsif v_unit_type_id = 458 then
    --percent of total  total_system_cost*rebate_amount
  end if;


  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
