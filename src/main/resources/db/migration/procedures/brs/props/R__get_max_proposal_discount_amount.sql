drop function if exists brs.get_max_proposal_discount_amount(p_proposal_id bigint);
CREATE OR REPLACE FUNCTION brs.get_max_proposal_discount_amount(p_proposal_id bigint)
  returns numeric AS
$BODY$
declare
  v_closer_user_id    bigint;
  v_amount            numeric;
  v_primary_financier bigint;
  v_source_id         bigint;
  v_system_size       numeric;
  v_loan_term         bigint;
  v_interest_rate     numeric;
  v_project_id        bigint;
BEGIN
--   v_primary_financier = -1;
--   v_loan_term = -1;
--   v_interest_rate = 0;
--
--
  select pps.project_id,ppscfv.numeric_value
  into v_project_id,v_system_size
  from brs.proposal p
         inner join flow.project_process_step pps on pps.id = p.project_process_step_id
         left join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and custom_field_group_assignment_id = 22561
  where p.id = p_proposal_id;
--
--   select closer_user_id
--   into v_closer_user_id
--   from brs.project_details pd
--   where pd.project_id = v_project_id;
--
--   select pcfv.int_value
--   into v_source_id
--   from flow.project_custom_field_value pcfv
--   where pcfv.project_id = v_project_id
--     and pcfv.custom_field_group_assignment_id = 17280
--     and pcfv.int_value is not null;
--
--   if v_closer_user_id is not null and v_system_size is not null then
--
--
--     select coalesce(round(cp.total * case
--                                        when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99
--                                          then 0
--                                        else v_system_size::numeric end
--                             - case
--                                 when cpsa.fee_type_id = 1 then coalesce(case
--                                                                           when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99
--                                                                             then 0
--                                                                           else v_system_size::numeric end *
--                                                                         cpsa.fee_amount, 0)
--                                 else
--                                   coalesce(cpsa.fee_amount, 0) end, 2),
--                     0) * 2 * .8
--     from brs.project_details pd
--            inner join brs.project_commission pc on pc.project_id = pd.project_id
--            inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
--            inner join brs.commission_plan_user cpu on cpu.commission_plan_id = cp.id and cpu.user_id = v_closer_user_id
--       and cpu.end_date is null
--            left join brs.commission_plan_source_allocation cpsa
--                      on cpsa.commission_plan_id = cp.id and cpsa.milestone_id = 2 and
--                         cpsa.source_id = v_source_id
--     where pd.closer_user_id = v_closer_user_id
--     into v_amount;
--   end if;
--
--   if (v_amount is null or v_amount = 0) and v_system_size is not null then
--     v_amount = v_system_size * 100 * 2 * .8;
--   end if;
  return v_system_size*200;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
