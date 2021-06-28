CREATE OR REPLACE FUNCTION brs.populate_system_and_financial_fields(p_project_id integer,p_process_step_id integer,p_project_process_step_id integer)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_proposal_history_id integer;
    v_design_log_history_id integer;
    _key   text;
    _value text;
    v_company_id integer;
    v_number_of_arrays integer;
    v_number_of_pitch integer;
    v_loan_type varchar;
BEGIN

    select ppscfv.int_value
    into v_proposal_history_id
    from flow.project_process_step pps
     inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
     inner join flow.custom_field_group_assignment cfga2 on cfga2.id = ppscfv.custom_field_group_assignment_id
     inner join flow.custom_field cf2  on cf2.id = cfga2.custom_field_id
    where pps.id = p_project_process_step_id
      and cf2.parent_custom_field_id = 9989;


    select ppscfv.int_value
    into v_design_log_history_id
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
             inner join flow.custom_field_group_assignment cfga2 on cfga2.id = ppscfv.custom_field_group_assignment_id
             inner join flow.custom_field cf2  on cf2.id = cfga2.custom_field_id
    where pps.id = p_project_process_step_id
      and cf2.parent_custom_field_id = 10495;


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

    select greatest(pitch_mp1::integer,pitch_mp2::integer,pitch_mp3::integer,pitch_mp4::integer,pitch_mp5::integer,pitch_mp6::integer),
           case
               WHEN number_of_modules_mp6::integer > 0 THEN 6
               WHEN number_of_modules_mp5::integer > 0 THEN 5
               WHEN number_of_modules_mp4::integer > 0 THEN 4
               WHEN number_of_modules_mp3::integer > 0 THEN 3
               WHEN number_of_modules_mp2::integer > 0 THEN 2
               ELSE 1
               END
    into v_number_of_pitch,v_number_of_arrays
    from brs.design_log_history
    where id = v_design_log_history_id;

    FOR _key, _value IN
        select f.key,f.value
        from (

                 select jsonb_build_object((select cfga.id
                                            from flow.custom_field cf
                                                     inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                            where cf.parent_custom_field_id = 10062
                                              and cfga.archived is false and cf.archived is false and cfg.archived is false
                                              and cf.company_id = v_company_id
                                              and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                             from flow.list_of_value lov
                                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                                 and cf.company_id = v_company_id
                                                                                                 and cf.parent_custom_field_id = 10062 and cf.archived is false
                                                                                             where lov2.name::text = plh.loan_product),
                                            (select cfga.id
                                            from flow.custom_field cf
                                                     inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                            where cf.parent_custom_field_id = 10387
                                              and cfga.archived is false and cf.archived is false and cfg.archived is false
                                              and cf.company_id = v_company_id
                                              and cfg.process_step_id = p_process_step_id), plh.referral_promotion::numeric,
                                           (select cfga.id
                                            from flow.custom_field cf
                                                     inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                            where cf.parent_custom_field_id = 10352
                                              and cfga.archived is false and cf.archived is false and cfg.archived is false
                                              and cf.company_id = v_company_id
                                              and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                             from flow.list_of_value lov
                                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                                 and cf.company_id = v_company_id
                                                                                                 and cf.parent_custom_field_id = 10352 and cf.archived is false
                                                                                             where upper(substring(plh.panel,1,position(' ' in plh.panel)-1)) = upper(lov2.name)),
                             (select cfga.id
                              from flow.custom_field cf
                                       inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                       inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                              where cf.parent_custom_field_id = 10329
                                and cfga.archived is false and cf.archived is false and cfg.archived is false
                                and cf.company_id = v_company_id
                                and cfg.process_step_id = p_process_step_id), plh.panel_wattage::integer,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10468
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), round(plh.system_size::numeric/1000,2),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10141
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), plh.year_1_kwh_output::integer,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10328
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), plh.panel_number::integer,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10318
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                              from flow.list_of_value lov
                                                                                       inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                       inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                  and cf.company_id = v_company_id
                                                                                  and cf.parent_custom_field_id = 10318 and cf.archived is false
                                                                              where upper(inverter_custom_getting) = upper(lov2.name)),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10431
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), round(plh.total_cost::numeric,2)::numeric,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10307
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), case when v_loan_type != 'Cash' then
                                                                                plh.loan_amount::numeric
                                                                                else 0.00::numeric end,
                           (select cfga.id
                            from flow.custom_field cf
                                     inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                     inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                            where cf.parent_custom_field_id = 10317
                              and cfga.archived is false and cf.archived is false and cfg.archived is false
                              and cf.company_id = v_company_id
                              and cfg.process_step_id = p_process_step_id), plh.interest_rate::numeric*100::numeric,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10460
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                              from flow.list_of_value lov
                                                                                       inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                       inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                  and cf.company_id = v_company_id
                                                                                  and cf.parent_custom_field_id = 10460 and cf.archived is false
                                                                              where plh.loan_term::integer = lov2.name::integer),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10009
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), v_number_of_pitch,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10323
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), v_number_of_arrays,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10430
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), round(coalesce(promotion_eighteen_months_free::numeric,0)::numeric,2)::numeric,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10324
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), plh.number_of_promotion_payments,
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10428
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id), coalesce(round((round((coalesce(non_standard_work_1_cost::numeric,0)),2) + round((coalesce(non_standard_work_2_cost::numeric,0)),2) +
                                                                                             round((coalesce(non_standard_work_3_cost::numeric,0)),2)),2),0),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10062
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id),(select lov2.id
                                                                             from flow.list_of_value lov
                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                 and cf.company_id = v_company_id
                                                                                 and cf.parent_custom_field_id = 10062 and cf.archived is false
                                                                             where lov2.name::text = case when v_loan_type = 'Mosiac' and bp_plus_promotion = 'Yes' then 'BluePower Plus PrePaid'
                                                                                                          when bp_plus_promotion = 'Yes' then 'BluePower Plus' else 'BluePower' end),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10183
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id),(select lov2.id
                                                                             from flow.list_of_value lov
                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                 and cf.company_id = v_company_id
                                                                                 and cf.parent_custom_field_id = 10183 and cf.archived is false
                                                                             where lov2.name::text = case when v_loan_type = 'Mosiac' then 'Mosaic' else v_loan_type end),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10404
                               and cfga.archived is false and cf.archived is false and cfg.archived is false
                               and cf.company_id = v_company_id
                               and cfg.process_step_id = p_process_step_id),(select lov2.id
                                                                             from flow.list_of_value lov
                                                                                      inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                      inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                 and cf.company_id = v_company_id
                                                                                 and cf.parent_custom_field_id = 10404 and cf.archived is false
                                                                             where lov2.name::text = case when plh.optional_down_payment::numeric >  0 then 'Cash' else null end),
                            (select cfga.id
                             from flow.custom_field cf
                                      inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                      inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                             where cf.parent_custom_field_id = 10429
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
        --raise notice 'cfga% value %',_key,_value;
        perform flow.set_pps_cfv(p_project_id,99999999, _key::integer, _value);
    END LOOP;


END
$function$


