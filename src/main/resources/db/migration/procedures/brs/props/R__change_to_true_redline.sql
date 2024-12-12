drop procedure if exists brs.change_to_true_redline(
  p_project_id bigint, boolean);
CREATE OR REPLACE procedure brs.change_to_true_redline(
  p_project_id bigint,
  p_update_all_plh boolean default false)
AS
$BODY$
declare

  v_minimum_funding_amount_per_watt   numeric;
  v_markup                            numeric;
  v_closer_commission_amount          numeric;
  v_df_pps_id                         bigint;
  v_booking_pps_id                    bigint;
  v_pcfv_commission_strategy_id       bigint;
  v_pcfv_desired_commission_id        bigint;
  x                                   record;
  v_df_cs_id                          bigint;
  v_df_dca_id                         bigint;
  v_booking_cs_id                     bigint;
  v_booking_dca_id                    bigint;
  v_plh_id                            bigint;
  v_override_plan_id                  bigint;
  v_override_plan_name                text;
  v_source_id                         bigint;
  v_non_self_gen_source_id            bigint;
  v_round_robin_id                    bigint;
  v_digital_lead_cost                 numeric;
  v_setter_lead_cost                  numeric;
  v_commission_strategy_id            bigint;
  v_lead_cost                         numeric;
  v_lead_cost_adder                   numeric;
  v_desired_commission_amount         numeric;
  v_override_plan_base_price_per_watt numeric;
BEGIN
  v_override_plan_id = null;
  v_digital_lead_cost = 0::numeric;
  v_setter_lead_cost = 0::numeric;
  select op.id, op.name, pd.source, c.round_robin_id, cocfv.numeric_value
  into v_override_plan_id,v_override_plan_name,v_source_id,v_round_robin_id,v_override_plan_base_price_per_watt
  from brs.financial_details f
         inner join brs.project_details pd on pd.project_id = f.project_id
         inner join brs.override_plan_assigned_user opau on opau.user_id = pd.closer_user_id and end_date is null
         inner join brs.override_plan op on opau.override_plan_id = op.id
         left join brs.commission_override_custom_field_value cocfv
                   on cocfv.override_plan_id = op.id and cocfv.custom_field_group_assignment_id = 871
         left join flow.postal_code c on c.postal_code = pd.project_postal_code and c.archived is false
  where f.project_id = p_project_id;

  if v_round_robin_id is not null then
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 975)') ->>
            'value')::numeric,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 976)') ->>
            'value')::numeric
    into v_digital_lead_cost,v_setter_lead_cost
    from brs.get_proposal_version_value(178, array [(977, null, v_round_robin_id, null)::ProposalFieldFilter],
                                        'PROPOSAL_LEAD_COST_ADDERS');
  end if;

  --   select lov.id
--   into v_non_self_gen_source_id
--   from flow.list_of_value lov
--   where parent_id = 520
--     and id not in (523, 524, 530, 20016)
--     and lov.id = v_source_id
--     and archived is false;

  if v_override_plan_id is not null and v_override_plan_base_price_per_watt is not null then

    update brs.project_override po
    set override_plan_id = v_override_plan_id
    where project_id = p_project_id;

    update brs.financial_details fd
    set override_plan_id     = v_override_plan_id,
        override_plan        = v_override_plan_name,
        override_plan_status = 'ACTIVE',
        date_modified        = now()
    where project_id = p_project_id;

    for x in select p.id, p.proposal_nbr, pps.project_id
             from brs.proposal p
                    inner join flow.project_process_step pps on pps.id = p.project_process_step_id
             where pps.project_id = p_project_id
      loop

        v_df_pps_id = null;
        v_booking_cs_id = null;
        v_booking_dca_id = null;
        v_df_dca_id = null;
        v_df_cs_id = null;
        v_booking_pps_id = null;
        v_markup = 0;
        v_closer_commission_amount = 0;
        v_minimum_funding_amount_per_watt = null;
        v_plh_id = null;
        v_pcfv_commission_strategy_id = null;
        v_pcfv_desired_commission_id = null;
        v_commission_strategy_id = null;
        v_lead_cost_adder = null;
        v_desired_commission_amount = null;


        select loan_fundingw, h.id, h.commission_strategy_id, h.lead_cost_adder, desired_commission_amount
        into v_minimum_funding_amount_per_watt,v_plh_id,v_commission_strategy_id,v_lead_cost_adder,v_desired_commission_amount
        from brs.proposal_log_history h
        where h.project_id = x.project_id
          and h.proposal_nbr = x.proposal_nbr;


        select p.id
        into v_df_pps_id
        from flow.project_process_step p
               inner join flow.project_process_step_custom_field_value v on v.project_process_step_id = p.id and
                                                                            v.custom_field_group_assignment_id = 19449
        where p.project_id = x.project_id
          and v.int_value = v_plh_id
          and p.process_step_id = 3355
          and p.main is true;


        select p.id
        into v_booking_pps_id
        from flow.project_process_step p
               inner join flow.project_process_step_custom_field_value v on v.project_process_step_id = p.id and
                                                                            v.custom_field_group_assignment_id = 1434
        where p.project_id = p_project_id
          and v.int_value = v_plh_id
          and p.process_step_id = 4
          and p.main is true;

        select pcfv.id
        into v_pcfv_commission_strategy_id
        from brs.proposal_custom_field_value pcfv
        where pcfv.proposal_id = x.id
          and pcfv.custom_field_group_assignment_id = 581;

        select pcfv.id
        into v_pcfv_desired_commission_id
        from brs.proposal_custom_field_value pcfv
        where pcfv.proposal_id = x.id
          and pcfv.custom_field_group_assignment_id = 454;

        v_lead_cost = 0.00::numeric;
        v_lead_cost = case
                        when v_source_id = 525 and v_setter_lead_cost::numeric > 0::numeric then
                          v_setter_lead_cost
                        when v_source_id = any (array [16766,19099,527,522,528]) and v_digital_lead_cost::numeric > 0::numeric
                          then
                          v_digital_lead_cost
                        else 0::numeric end;

        v_markup = v_minimum_funding_amount_per_watt - brs.get_minimum_price_per_watt(x.id) - v_lead_cost;

        if v_commission_strategy_id in (26056, 24101, 24102) then
          if v_commission_strategy_id != 26056 then
            update brs.proposal_log_history plh2
            set loan_fundingw     = v_minimum_funding_amount_per_watt - v_lead_cost,
                lead_cost_adder   = v_lead_cost,
                total_adder_costs = case
                                      when (v_lead_cost_adder is null or v_lead_cost_adder::numeric = 0::numeric)
                                        then coalesce(total_adder_costs::numeric, 0.00::numeric) + v_lead_cost
                                      else total_adder_costs::numeric end
            where plh2.id = x.id;


            v_closer_commission_amount = round(v_markup, 3);
          else
            v_closer_commission_amount = v_desired_commission_amount;
          end if;

          if v_booking_pps_id is not null then
            select ppscfv.id
            into v_booking_cs_id
            from flow.project_process_step s
                   inner join flow.project_process_step_custom_field_value ppscfv
                              on ppscfv.project_process_step_id = s.id
            where ppscfv.custom_field_group_assignment_id = 27105
              and s.id = v_booking_pps_id
              and s.main is true;

            select ppscfv.id
            into v_booking_dca_id
            from flow.project_process_step s
                   inner join flow.project_process_step_custom_field_value ppscfv
                              on ppscfv.project_process_step_id = s.id
            where ppscfv.custom_field_group_assignment_id = 26943
              and s.id = v_booking_pps_id
              and s.main is true;

            if v_booking_cs_id is not null then
              update flow.project_process_step_custom_field_value
              set int_value = 26056::bigint
              where id = v_booking_cs_id;
            else
              insert into flow.project_process_step_custom_field_value(project_process_step_id,
                                                                       custom_field_group_assignment_id, int_value,
                                                                       date_created, date_modified, created_by_id,
                                                                       modified_by_id)
              values (v_booking_pps_id, 27105, 26056::bigint, now(), now(), 99999999, 99999999);
            end if;

            if v_booking_dca_id is not null then
              update flow.project_process_step_custom_field_value
              set numeric_value = v_closer_commission_amount
              where id = v_booking_dca_id;
            else
              insert into flow.project_process_step_custom_field_value(project_process_step_id,
                                                                       custom_field_group_assignment_id, numeric_value,
                                                                       date_created, date_modified, created_by_id,
                                                                       modified_by_id)
              values (v_booking_pps_id, 26943, v_closer_commission_amount, now(), now(), 99999999, 99999999);
            end if;
          end if;

          if v_df_pps_id is not null then
            select ppscfv.id
            into v_df_cs_id
            from flow.project_process_step s
                   inner join flow.project_process_step_custom_field_value ppscfv
                              on ppscfv.project_process_step_id = s.id
            where ppscfv.custom_field_group_assignment_id = 27107
              and s.id = v_df_pps_id
              and s.main is true;

            select ppscfv.id
            into v_df_dca_id
            from flow.project_process_step s
                   inner join flow.project_process_step_custom_field_value ppscfv
                              on ppscfv.project_process_step_id = s.id
            where ppscfv.custom_field_group_assignment_id = 26166
              and s.id = v_df_pps_id
              and s.main is true;

            if v_df_cs_id is not null then
              update flow.project_process_step_custom_field_value
              set int_value = 26056::bigint
              where id = v_df_cs_id;
            else
              insert into flow.project_process_step_custom_field_value(project_process_step_id,
                                                                       custom_field_group_assignment_id, int_value,
                                                                       date_created, date_modified, created_by_id,
                                                                       modified_by_id)
              values (v_df_pps_id, 27107, 26056::bigint, now(), now(), 99999999, 99999999);
            end if;

            if v_df_dca_id is not null then
              update flow.project_process_step_custom_field_value
              set numeric_value = v_closer_commission_amount
              where id = v_df_dca_id;
            else
              insert into flow.project_process_step_custom_field_value(project_process_step_id,
                                                                       custom_field_group_assignment_id, numeric_value,
                                                                       date_created, date_modified, created_by_id,
                                                                       modified_by_id)
              values (v_df_pps_id, 26166, v_closer_commission_amount, now(), now(), 99999999, 99999999);
            end if;
          end if;


          update brs.proposal_log_history plh
          set commission_strategy_id    = 26056,
              desired_commission_amount = v_closer_commission_amount,
              date_modified             = now()
          where plh.id = v_plh_id;

          if v_pcfv_commission_strategy_id is not null then
            update brs.proposal_custom_field_value pcfv
            set int_value = 26056
            where id = v_pcfv_commission_strategy_id;
          else
            insert into brs.proposal_custom_field_value(proposal_id, custom_field_group_assignment_id, int_value,
                                                        date_created, date_modified, created_by_id, modified_by_id)
            values (x.id, 581, 26056, now(), now(), 99999999, 99999999);
          end if;

          if v_pcfv_desired_commission_id is not null then
            update brs.proposal_custom_field_value pcfv
            set numeric_value = v_closer_commission_amount * 1000
            where id = v_pcfv_desired_commission_id;
          else
            insert into brs.proposal_custom_field_value(proposal_id, custom_field_group_assignment_id, numeric_value,
                                                        date_created, date_modified, created_by_id, modified_by_id)
            values (x.id, 454, v_closer_commission_amount * 1000, now(), now(), 99999999, 99999999);
          end if;
        end if;
      end loop;

    update brs.project_commission pc
    set commission_plan_id = 67
    where project_id = p_project_id;

    update brs.financial_details fd
    set commission_plan_id       = 67,
        commission_plan          = 'True Redline',
        commission_plan_status   = 'ACTIVE',
        date_modified            = now(),
        commission_strategy      = 26056,
        commission_strategy_name = 'Redline'
    where project_id = p_project_id;

    call brs.reset_financial_details(p_project_id);

    perform flow.set_project_cfv(p_project_id, 2356764, 24819, true::text, true);
  else
    raise notice 'project_id is mission override plan or base price is null %',p_project_id;
  end if;
END
$BODY$
  LANGUAGE plpgsql;

