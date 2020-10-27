CREATE OR REPLACE FUNCTION brs.populate_system_and_financial_fields(p_project_id integer,p_process_step_id integer,p_project_process_step_id integer)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_proposal_history_id integer;
    _key   text;
    _value text;
    v_company_id integer;
BEGIN
    select ppscfv.int_value
    into v_proposal_history_id
    from flow.project_process_step pps
     inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
     inner join flow.custom_field_group_assignment cfga2 on cfga2.id = ppscfv.custom_field_group_assignment_id
     inner join flow.custom_field cf2  on cf2.id = cfga2.custom_field_id
    where pps.id = p_project_process_step_id
      and cf2.field_name = 'Proposal Log Number';

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
                                              and cfg.process_step_id = p_process_step_id), plh.referral_promotion,
                                           124, plh.panel,
                                           125, plh.panel_wattage,
                                           126, plh.system_size,
                                           127, plh.year_1_kwh_output) as me
                 from brs.proposal_log_history plh
                 where id = v_proposal_history_id and
                       plh.project_id = p_project_id) as t
                 left join lateral jsonb_each_text(t.me) f on true
    LOOP
        perform flow.set_pps_cfv(p_project_id, _key, _value);
    END LOOP;


END;
$function$
