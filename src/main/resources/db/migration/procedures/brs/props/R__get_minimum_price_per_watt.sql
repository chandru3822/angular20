drop function if exists brs.get_minimum_price_per_watt(p_proposal_id bigint);
CREATE OR REPLACE FUNCTION brs.get_minimum_price_per_watt(p_proposal_id bigint)
  returns table (
                redline_price numeric,
                override_plan_id bigint
                )
AS
$BODY$
declare
  v_proposal_version_id         bigint;
  v_closer_user_id              bigint;
  v_allocation_sum              numeric;
  v_closer_org_id               bigint;
  v_override_plan_id            bigint;
  v_template_org_id             bigint;
  v_closer_name                 text;
  v_base_price_per_watt         numeric;
  v_user_commission_strategy_id bigint[];
  v_redline_amount numeric;
BEGIN


  select p.proposal_version_id,
         pd.closer_user_id,
         pd.closer_office,
         opau.override_plan_id,
         pd.closer_name,
         coalesce(cocfv.numeric_value,cocfv1.numeric_value)
  into v_proposal_version_id,v_closer_user_id,v_closer_org_id,v_override_plan_id,v_closer_name,v_base_price_per_watt
  from brs.proposal p
         inner join flow.project_process_step pps on pps.id = p.project_process_step_id
         inner join brs.project_details pd on pd.project_id = pps.project_id
         inner join brs.financial_details fd on fd.project_id = pd.project_id
         left join brs.override_plan o on o.id = fd.override_plan_id

         left join brs.commission_override_custom_field_value cocfv
                   on cocfv.override_plan_id = o.id and cocfv.custom_field_group_assignment_id = 871 --stage
         left join brs.override_plan_assigned_user opau on opau.user_id = pd.closer_user_id and
                                                           opau.end_date is null
         left join brs.commission_override_custom_field_value cocfv1
                   on cocfv1.override_plan_id = opau.override_plan_id and cocfv1.custom_field_group_assignment_id = 871 --stage
  where p.id = p_proposal_id;

  select int_array_value
  into v_user_commission_strategy_id
  from flow."user" u
         inner join flow.user_custom_field_value ucfv
                    on ucfv.user_id = u.id and custom_field_group_assignment_id = 26897
  where u.id = v_closer_user_id;

  if array_length(v_user_commission_strategy_id, 1) = 1 and v_user_commission_strategy_id && '{24102,24871,26056}' then

    select org_id
    into v_template_org_id
    from brs.override_plan op
           inner join brs.commission_override_custom_field_value cocfv
                      on cocfv.override_plan_id = op.id and cocfv.custom_field_group_assignment_id = 870--stage value
    where org_id = v_closer_org_id
      and cocfv.int_value = any (v_user_commission_strategy_id)
      and status_id = 2;
  end if;


  if v_override_plan_id is null then
    if v_template_org_id is null then
      return query select null::numeric,null::bigint;
      --raise exception 'No Override Plan is assigned for = %, please contact Rep Pay',v_closer_name;
    elsif v_template_org_id is not null then
      select *
      into v_allocation_sum
      from brs.insert_override_plan_from_template(
        v_closer_org_id, v_closer_user_id);
      select p.proposal_version_id,
             pd.closer_user_id,
             pd.closer_office,
             opau.override_plan_id,
             pd.closer_name,
             coalesce(cocfv.numeric_value,cocfv1.numeric_value)
      into v_proposal_version_id,v_closer_user_id,v_closer_org_id,v_override_plan_id,v_closer_name,v_base_price_per_watt
      from brs.proposal p
             inner join flow.project_process_step pps on pps.id = p.project_process_step_id
             inner join brs.project_details pd on pd.project_id = pps.project_id
             inner join brs.financial_details fd on fd.project_id = pd.project_id
             left join brs.override_plan o on o.id = fd.override_plan_id

             left join brs.commission_override_custom_field_value cocfv
                       on cocfv.override_plan_id = o.id and cocfv.custom_field_group_assignment_id = 871 --stage
             left join brs.override_plan_assigned_user opau on opau.user_id = pd.closer_user_id and
                                                               opau.end_date is null
             left join brs.commission_override_custom_field_value cocfv1
                       on cocfv1.override_plan_id = opau.override_plan_id and cocfv1.custom_field_group_assignment_id = 871 --stage
      where p.id = p_proposal_id;
    else
      if v_base_price_per_watt is null or v_base_price_per_watt = 0 then
        raise exception 'The Redline funding amount can not be found, please contact Rep Pay';
      end if;
    end if;
  else
    if v_base_price_per_watt is null or v_base_price_per_watt = 0 then
      return query select null::numeric,null::bigint;
    else
      select sum(opru.m1_allocation + opru.m2_allocation)
      into v_allocation_sum
      from brs.override_plan_receiving_user opru
      where opru.override_plan_id = v_override_plan_id;
    end if;
  end if;
  v_redline_amount = round(coalesce((v_allocation_sum / 1000)::numeric, 0) + coalesce(v_base_price_per_watt, 0), 3)::numeric;
  return query select v_redline_amount,v_override_plan_id::bigint;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
