CREATE OR REPLACE FUNCTION brs.populate_system_and_financial_fields_for_booking(p_project_id integer,p_process_step_id integer,p_project_process_step_id integer)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_proposal_history_id integer;
    _key   text;
    _value text;
    v_company_id integer;
    v_loan_type varchar;
BEGIN

    select ppscfv.int_value
    into v_proposal_history_id
    from flow.project_process_step pps
     inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
     inner join flow.custom_field_group_assignment cfga2 on cfga2.id = ppscfv.custom_field_group_assignment_id
     inner join flow.custom_field cf2  on cf2.id = cfga2.custom_field_id
    where pps.id = p_project_process_step_id
      and cf2.field_name = 'Proposal Log Number';



    select substring(loan_type,1,position(' ' in loan_type)-1)
    into v_loan_type
    from brs.proposal_log_history
    where id = v_proposal_history_id;

    select cp.company_id
    into v_company_id
    from flow.project p
    inner join flow.company_process cp on cp.process_id = p.company_process_id
    where p.id = p_project_id
    limit 1;


    FOR _key, _value IN
        select f.key,f.value
        from (

                 select jsonb_build_object((select cfga.id
                                            from flow.custom_field cf
                                                     inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                            where cf.field_name = 'Referral Promotion Amount'
                                              and cfga.archived is false and cf.archived is false and cfg.archived is false
                                              and cf.company_id = v_company_id
                                              and cfg.process_step_id = p_process_step_id), plh.referral_promotion::numeric,
                                           (select cfga.id
                                            from flow.custom_field cf
                                                     inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                            where cf.field_name = 'Panel Brand'
                                              and cfga.archived is false and cf.archived is false and cfg.archived is false
                                              and cf.company_id = v_company_id
                                              and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                             from flow.list_of_value lov
                                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                                 and cf.company_id = v_company_id
                                                                                                 and cf.field_name = 'Panel Brand' and cf.archived is false
                                                                                             where upper(substring(plh.panel,1,position(' ' in plh.panel)-1)) = upper(lov2.name)),
                             (select cfga.id
                              from flow.custom_field cf
                                       inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                       inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                              where cf.field_name = 'Panel Watts'
                                and cfga.archived is false and cf.archived is false and cfg.archived is false
                                and cf.company_id = v_company_id
                                and cfg.process_step_id = p_process_step_id), plh.panel_wattage::integer,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'System Size (kW)'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), round(plh.system_size::numeric/1000,2),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Panel Quantity'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), plh.panel_number::integer,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Inverter Brand'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                              from flow.list_of_value lov
                                                                                       inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                       inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                  and cf.company_id = v_company_id
                                                                                  and cf.field_name = 'Inverter Brand' and cf.archived is false
                                                                              where upper(inverter_custom_getting) = upper(lov2.name)),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Total System Price'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), round(plh.total_cost::numeric,2)::numeric,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Loan Amount'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), plh.loan_amount::numeric,
                           (select cfga.id
                            from flow.custom_field cf
                                     inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                            where cf.field_name = 'Interest Rate'
                              and cfga.archived is false and cf.archived is false and cfg.archived is false
                              and cf.company_id = v_company_id
                              and cfg.process_step_id = p_process_step_id), plh.interest_rate::numeric,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Loan Term'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                              from flow.list_of_value lov
                                                                                       inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                       inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                  and cf.company_id = v_company_id
                                                                                  and cf.field_name = 'Loan Term' and cf.archived is false
                                                                              where plh.loan_term::integer = lov2.name::integer),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Total Promotion Amount'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), round(coalesce(promotion_eighteen_months_free::numeric,0)::numeric,2)::numeric,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Number of Promotion Payments'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), case when coalesce(promotion_eighteen_months_free::numeric,0)::numeric > 0 and
                                                                                       pd.proposal_complete_date::date between '2020-03-25'::date and '2020-04-30'::date then 1
                                                                                  when coalesce(promotion_eighteen_months_free::numeric,0)::numeric > 0 and
                                                                                       (pd.proposal_complete_date::date < '2020-03-25'::date or  pd.proposal_complete_date::date > '2020-04-30'::date) then 18 else 0 end,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Total Ancillary Cost with Fees'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), coalesce(round((round((non_standard_work_1_cost::numeric),2) + round((non_standard_work_2_cost::numeric),2) +
                                                                                             round((non_standard_work_3_cost::numeric),2)),2),0),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Product'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id),(select lov2.id
                                                                             from flow.list_of_value lov
                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                 and cf.company_id = v_company_id
                                                                                 and cf.field_name = 'Product' and cf.archived is false
                                                                             where lov2.name::text = case when v_loan_type = 'Mosiac' and bp_plus_promotion = 'Yes' then 'BluePower Plus PrePaid'
                                                                                                          when bp_plus_promotion = 'Yes' then 'BluePower Plus' else 'BluePower' end),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Primary Financier'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id),(select lov2.id
                                                                             from flow.list_of_value lov
                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                 and cf.company_id = v_company_id
                                                                                 and cf.field_name = 'Primary Financier' and cf.archived is false
                                                                             where lov2.name::text = case when v_loan_type = 'Mosiac' then 'Mosaic' else v_loan_type end),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Secondary Financier'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id),(select lov2.id
                                                                             from flow.list_of_value lov
                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                 and cf.company_id = v_company_id
                                                                                 and cf.field_name = 'Secondary Financier' and cf.archived is false
                                                                             where lov2.name::text = case when plh.optional_down_payment::numeric >  0 then 'Cash' else null end),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.field_name = 'Total Cash Down Payment'
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id),( case when (v_loan_type = 'Cash' and plh.loan_amount::numeric is null) then 0.00::numeric
                                                                                      when (v_loan_type = 'Cash' and plh.loan_amount::numeric > 0.00::numeric) then coalesce(round(plh.loan_amount::numeric,2),0)::numeric
                                                                                      when (v_loan_type != 'Cash' and optional_down_payment::numeric is null) then 0.00::numeric
                                                                                      when (v_loan_type != 'Cash' and optional_down_payment::numeric > 0.00::numeric) then coalesce(round(optional_down_payment::numeric,2),0)::numeric
                                                                                      else 0.00::numeric end)) as me
                 from brs.proposal_log_history plh
                 inner join brs.project_details pd on pd.project_id = plh.project_id
                 where plh.id = v_proposal_history_id) as t
                 left join lateral jsonb_each_text(t.me) f on true
    LOOP
       -- raise notice 'cfga% value %',_key,_value;
        perform flow.set_pps_cfv(p_project_id,99999999, _key::integer, _value);
    END LOOP;


END
$function$


