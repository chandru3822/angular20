drop function if exists brs.set_override_plan_from_proposal(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.set_override_plan_from_proposal(p_project_id bigint)
  returns numeric
AS
$BODY$
declare
  v_closer_user_id       bigint;
  v_override_plan_id     bigint;
  v_closer_org_id        bigint;
  v_sum_allocation       numeric;
  v_new_override_plan_id bigint;
  v_fd_override_plan_id  bigint;
BEGIN


  select pd.closer_user_id, pd.closer_office, fd.override_plan_id
  into v_closer_user_id,v_closer_org_id,v_fd_override_plan_id
  from brs.project_details pd
         inner join brs.financial_details fd on fd.project_id = pd.project_id
         inner join flow."user" u on u.id = pd.closer_user_id
  where pd.project_id = p_project_id;

  select op.id,
         (select sum(opru.m1_allocation + opru.m2_allocation)
          from brs.override_plan_receiving_user opru
          where opru.override_plan_id = op.id)
  into v_override_plan_id,v_sum_allocation
  from brs.override_plan op
         inner join brs.override_plan_assigned_user opau
                    on opau.override_plan_id = op.id
  where case
          when v_fd_override_plan_id is not null then
            v_fd_override_plan_id = op.id
          else
            opau.end_date is null
              and op.position_id = 1 and opau.user_id = v_closer_user_id end;


  if v_override_plan_id is null then
    select *
    into v_sum_allocation
    from brs.insert_override_plan_from_template(v_closer_user_id);
  end if;

  return coalesce(v_sum_allocation/1000, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
