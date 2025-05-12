drop function if exists brs.get_selected_custom_auto_adders(p_proposal_id bigint, p_commission_strategy_id bigint, p_storage_id bigint,p_financial_product_id bigint);
CREATE OR REPLACE FUNCTION brs.get_selected_custom_auto_adders(p_proposal_id bigint, p_commission_strategy_id bigint, p_storage_id bigint,p_financial_product_id bigint)
  returns TABLE(adder_type text, id bigint, field_name character varying, selected_project_adder boolean, selected_proposal_adder boolean, selected_adder_amount numeric, custom_proposal_adder_amount numeric, custom_project_adder_amount numeric, auto_applied_adder_amount numeric) as
$BODY$
BEGIN

  return query
    with proposal_data as (select gpd.project_id,
                                  gpd.version_id,
                                  gpd.proposal_id as id,
                                  gpd.system_size as system_size,
                                  gpd.panel_quantity     as panel_quantity,
                                  gpd.utility_company_id     as utility_id,
                                  gpd.state_id                  as state_id,
                                  gpd.source_id,
                                  gpd.panel_brand_id     as panel_brand_id,
                                  gpd.panel_watts     as panel_watts,
                                  gpd.inverter_brand_id    as inverter_brand_id,
                                  gpd.postal_code,
                                  gpd.misc_adders_array,
                                  gpd.rete_incentive_applied,
                                  gpd.unapproved_zip_code_adder,
                                  gpd.adder_amount
                           from brs.get_proposal_details(p_proposal_id)gpd),
         financier as(
           select apr,
                  financial_option,
                  reamortized_payment_factor_without_itc_paydown,
                  loan_term_id,
                  loan_term,
                  dealer_fee,
                  reamortization_factor,
                  financier_id,
                  financier,
                  initial_payment_factor
           from proposal_data pd
                  cross join brs.get_proposal_finance_products(pd.version_id, p_financial_product_id)
         ),
         custom_adders as (select pk, proposal_adder_cfga, project_adder_cfga,adder_name
                           from proposal_data pd
                                  cross join brs.get_proposal_custom_adders(pd.version_id)),
         adder_cfga as (select (select string_to_array(value, ',') as cfgas
                                from flow.company_configuration_value
                                where code = 'PARTNER_ADDER_CFGA')::bigint[]),
         available_adders as (select lov.id, lov.name
                              from adder_cfga ac
                                     inner join flow.custom_field_group_assignment cfga on cfga.id = any (ac.cfgas)
                                     inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                     inner join flow.list_of_value lov on lov.parent_id = cf.list_of_value_id)
    select 'custom_adders'                                                                             as adder_type,
           cfga.id,
           md.adder_name::character varying,
           null::boolean                                                                               as selected_project_adder,
           null::boolean                                                                               as selected_proposal_adder,
           null::numeric as selected_adder_amount,
           (select coalesce((select pscfv.numeric_value
                             from brs.proposal_custom_field_value pscfv
                                    inner join brs.proposal p on p.id = pscfv.proposal_id
                                    inner join flow.project_process_step pps on pps.id = p.project_process_step_id
                                    inner join proposal_data p1 on p1.project_id = pps.project_id
                             where pscfv.custom_field_group_assignment_id = md.proposal_adder_cfga
                               and p.id = p1.id),
                            0))                                                                        as custom_proposal_adder_amount,
           (select coalesce((select pcfv.numeric_value
                             from flow.project_custom_field_value pcfv
                                    inner join proposal_data p3 on p3.project_id = pcfv.project_id
                             where pcfv.custom_field_group_assignment_id = md.project_adder_cfga),
                            0))                                                                        as custom_project_adder_amount,
           null::numeric                                                                               as auto_applied_adder_amount
    from brs.custom_field_group_assignment cfga
           inner join brs.custom_field cf on cf.id = cfga.custom_field_id
           inner join custom_adders md on md.proposal_adder_cfga = cfga.id
           inner join flow.custom_field_group_assignment cfga1 on cfga1.id = md.project_adder_cfga
           inner join flow.custom_field cf1 on cf1.id = cfga1.custom_field_id
    union
    select 'selected_adders'                           as adder_type,
           aa.id,
           aa.name,
           (select true as selected_project_adder
            from flow.project_custom_field_value pcfv
                   inner join proposal_data p1 on p1.project_id = pcfv.project_id
                   cross join adder_cfga ac3
            where pcfv.custom_field_group_assignment_id = any (ac3.cfgas)
              and aa.id = any (pcfv.int_array_value)),
           (select true as selected_proposal_adder
            from brs.proposal_custom_field_value pcfv1
                   inner join proposal_data p2 on p2.id = pcfv1.proposal_id
            where pcfv1.custom_field_group_assignment_id in (1337)--1337 prod
              and aa.id = any (pcfv1.int_array_value)),
           case
             when foo.fee_type = 459 then
               foo.amount
             when foo.fee_type = 13434 then
               foo.amount::numeric * p.panel_quantity
             when foo.fee_type = 460 then
               foo.amount::numeric * (p.system_size*1000) end as select_adder_amount,
           null::numeric,
           null::numeric,
           null::numeric
    from available_adders aa
           cross join proposal_data p
           join lateral (select *
                         from brs.get_proposal_selected_adders(p.version_id) ao
                         where (
                                 (aa.id = ANY (ao.adders) AND (ao.states = '{}' OR array_length(ao.states, 1) = 0) AND
                                  ao.utility_id IS NULL)
                                   OR (aa.id = ANY (ao.adders) AND p.state_id = ANY (ao.states) AND
                                       p.utility_id = ao.utility_id)
                                   OR (aa.id = ANY (ao.adders) AND p.state_id = ANY (ao.states))
                                   OR (aa.id = ANY (ao.adders) AND p.utility_id = ao.utility_id)
                                 )
      ) as foo on true
    union
    select 'auto_applied_adder' as adder_type,
           null::bigint,
           'Utility Adder',
           null::boolean,
           null::boolean,
           null::numeric as selected_adder_amount,
           null::numeric,
           null::numeric,
           ao.redline_utility_adder*(system_size*1000)
    from proposal_data p
           cross join brs.get_proposal_pricing(p.version_id, p.utility_id) ao
    union
    select 'auto_applied_adder' as adder_type,
           null::bigint,
           adder_name,
           null::boolean,
           null::boolean,
           null::numeric as selected_adder_amount,
           null::numeric,
           null::numeric,
           ao.misc_adder
    from proposal_data p
           cross join brs.get_individual_misc_adder_amount(p.version_id ,p.system_size, p.misc_adders_array,p.rete_incentive_applied,p.panel_quantity) ao
    where ao.misc_adder > 0
    --     union
--     select 'auto_applied_adder' as adder_type,
--            null::bigint,
--            'Source and State Adder',
--            null::boolean,
--            null::boolean,
--            null::numeric as selected_adder_amount,
--            null::numeric,
--            null::numeric,
--            case
--              when ao.unit_type_id = 459 then
--                ao.adder_amount
--              when ao.unit_type_id = 13434 then
--                ao.adder_amount::numeric * p.panel_quantity
--              when ao.unit_type_id = 460 then
--                ao.adder_amount::numeric * (p.system_size* 1000) end
--     from proposal_data p
--            cross join brs.get_proposal_source_state_adders(p.version_id, p.state_id, p.source_id) ao
    union
    select 'auto_applied_adder' as adder_type,
           null::bigint,
           'Small System Size Adder',
           null::boolean,
           null::boolean,
           null::numeric as selected_adder_amount,
           null::numeric,
           null::numeric,
           case
             when ao.small_system_size_unit_type_id = 459 then
               ao.small_system_size_adder
             when ao.small_system_size_unit_type_id = 13434 then
               ao.small_system_size_adder::numeric * p.panel_quantity
             when ao.small_system_size_unit_type_id = 460 then
               ao.small_system_size_adder::numeric * (p.system_size*1000) end
    from proposal_data p
           cross join brs.get_proposal_small_system_adders(p.version_id) ao
    where p.system_size between coalesce(lower_value::integer,0) and upper_value
    union
    select 'auto_applied_adder' as adder_type,
           null::bigint,
           'Panel Adder',
           null::boolean,
           null::boolean,
           null::numeric as selected_adder_amount,
           null::numeric,
           null::numeric,
           case
             when ao.panel_unit_type_id = 459 then
               ao.panel_adder_amount
             when ao.panel_unit_type_id = 13434 then
               ao.panel_adder_amount::numeric * p.panel_quantity
             when ao.panel_unit_type_id = 460 then
               ao.panel_adder_amount::numeric * (p.system_size*1000) end
    from proposal_data p
           cross join financier f
           cross join brs.get_proposal_panel_details(p.version_id, p.panel_brand_id, p.panel_watts) ao
    where case when ao.panel_states is not null and array_length(ao.panel_states,1) > 0 then
                 p.state_id = any (ao.panel_states) else 1=1 end and
      case when ao.primary_financier is not null then
             f.financier_id = ao.primary_financier else 1=1 end
    union
    select 'auto_applied_adder' as adder_type,
           null::bigint,
           'Inverter Adder',
           null::boolean,
           null::boolean,
           null::numeric as selected_adder_amount,
           null::numeric,
           null::numeric,
           case
             when ao.inverter_unit_type_id = 459 then
               ao.inverter_adder_amount
             when ao.inverter_unit_type_id = 13434 then
               ao.inverter_adder_amount::numeric * p.panel_quantity
             when ao.inverter_unit_type_id = 460 then
               ao.inverter_adder_amount::numeric * (p.system_size*1000) end
    from proposal_data p
           cross join brs.get_proposal_inverter_details(p.version_id, p.inverter_brand_id) ao
    union
    select 'auto_applied_adder' as adder_type,
           null::bigint,
           'Lead Cost Adder',
           null::boolean,
           null::boolean,
           null::numeric as selected_adder_amount,
           null::numeric,
           null::numeric,
           case
             when p_commission_strategy_id = 26056 and p.source_id = 525 then
               case
                 when ao.sett_lead_cost_cap is null then coalesce(ao.setter_lead_cost * (p.system_size * 1000), 0)
                 else least(ao.sett_lead_cost_cap, coalesce(setter_lead_cost * (p.system_size * 1000), 0)) end
             when p_commission_strategy_id = 26056 and p.source_id = any (array [16766,19099,522,528]) then
               case
                 when ao.digital_lead_cost_cap is null then coalesce(ao.digital_lead_cost * (p.system_size * 1000), 0)
                 else least(ao.digital_lead_cost_cap, coalesce(ao.digital_lead_cost * (p.system_size * 1000), 0)) end
             when p_commission_strategy_id = 26056 and p.source_id = 527 then
               case
                 when coalesce(ao.digital_lead_cost * (p.system_size * 1000), 0) is null
                   then coalesce(ao.organic_lead_cost * (p.system_size * 1000), 0)
                 else least(ao.organic_lead_cost_cap, coalesce(ao.organic_lead_cost * (p.system_size * 1000), 0)) end
             else
               null::numeric end
    from proposal_data p
           cross join brs.get_lead_cost_details(p.version_id, p.postal_code) ao

    union
    select 'auto_applied_adder' as adder_type,
           null::bigint,
           'Zone Adder',
           null::boolean,
           null::boolean,
           null::numeric as selected_adder_amount,
           null::numeric,
           null::numeric,
           p.adder_amount
    from proposal_data p
    order by 1, 2;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
