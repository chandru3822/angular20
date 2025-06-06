DROP FUNCTION IF EXISTS brs.get_proposal_details(p_proposal_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_details(p_proposal_id bigint)
  returns table
          (
            proposal_id                             bigint,
            version_id                              bigint,
            project_process_step_id                 bigint,
            friends_and_family                      boolean,
            down_payment_amount                     numeric,
            product_id                              bigint,
            product_name                            character varying,
            project_id                              bigint,
            proposal_archived                       boolean,
            contact_first_name                      varchar,
            contact_last_name                       varchar,
            project_name                            varchar,
            project_street1                         varchar,
            project_street2                         varchar,
            city                                    varchar,
            postal_code                             varchar,
            project_state                           varchar,
            project_state_abbrev                    varchar,
            contact_phone                           varchar,
            contact_email                           varchar,
            other_adder_and_discount_amount         numeric,
            other_adder_and_discount                character varying,
            storage_type_id                         bigint,
            storage_type                            varchar,
            main_panel_upgrade_cost                 numeric,
            structural_upgrade_cost                 numeric,
            reroof_cost                             numeric,
            tree_trimming_cost                      numeric,
            trenching_cost                          numeric,
            ac_unit_relocation_cost                 numeric,
            total_square_footage                    numeric,
            proposal_nbr                            bigint,
            display_name                            text,
            financial_product_id                    bigint,
            odoe_income_status                      bigint,
            desired_commission_amount               numeric,
            source_id                               bigint,
            admin_discount                          numeric,
            dealer                                  bigint,
            dealer_markup                           numeric,
            estimated_annual_energy_consumption_kwh bigint,
            first_year_production_estimate          bigint,
            system_size                             numeric,
            panel_watts                             bigint,
            panel_brand_id                          bigint,
            panel_brand                             character varying,
            state_id                                bigint,
            utility_company_id                      bigint,
            utility_company                         text,
            aurora_design_summary                   jsonb,
            led_light_bulbs                         bigint,
            smart_thermostat                        bigint,
            panel_quantity                          bigint,
            inverter_brand_id                       bigint,
            inverter_brand                          varchar,
            aurora_design_id                        text,
            unapproved_zip_code_adder               numeric,
            site_survey_time_adders                 bigint[],
            misc_adders_array                       bigint[],
            commission_strategy_id                  bigint,
            qualifies_for_incentive                 bigint[],
            adder_amount                            numeric,
            company_process_id                      bigint,
            virtual_sales_price_adjustment          numeric,
            system_size_ac                          numeric,
            panel_model                             text,
            qualifies_for_swr                       boolean,
            rete_incentive_applied                  boolean,
            rete_depreciation_incentive_amount      numeric,
            base_price_per_watt                     numeric,
            proposal_template_id                       bigint,
            solargraf_proudction jsonb,
            solargraf_materials jsonb,
            solargraf_panel jsonb
          )

AS
$BODY$
declare

BEGIN
  return query
    select prop.id                                                             as proposal_id,
           proposal_version_id,
           prop.project_process_step_id,
           coalesce(pcfv3.boolean_value, false),
           coalesce(pcfv4.numeric_value, 0),
           pcfv5.int_value,
           lov.name,
           p.id                                                                as project_id,
           prop.archived,
           c.first_name,
           c.last_name,
           p.project_name,
           p.street1,
           p.street2,
           p.city,
           p.postal_code,
           s.state,
           s.abbreviation                                                      as state_abbreviation,
           c.mobile,
           c.email,
           (pcfv7.numeric_value),
           lov6.name,
           pcfv8.int_value,
           lov2.name,
           pcfv10.numeric_value,
           pcfv11.numeric_value,
           pcfv12.numeric_value,
           pcfv13.numeric_value,
           pcfv14.numeric_value,
           pcfv15.numeric_value,
           pcfv16.numeric_value,
           prop.proposal_nbr::bigint,
           coalesce(prop.name, 'New Proposal') ||
           case
             when prop.revision_number = 0 then ''
             else ' (' || prop.revision_number::varchar || ')' end
             || ' - ' || prop.proposal_nbr || '.pdf'                           as display_name,
           pcfv17.int_value,
           pcfv18.int_value,
           pcfv19.numeric_value,
           d.source,
           pcfv20.numeric_value,
           pcfv21.int_value,
           pcfv22.numeric_value,
           ppscfv30.int_value,
           ppscfv31.int_value,
           ppscfv32.numeric_value,
           ppscfv33.int_value,
           ppscfv34.int_value,
           lov34.name,
           cs.state_id,
           ppscfv35.int_value,
           utility35.name,
           ppscfv36.json_value,
           ppscfv37.int_value,
           ppscfv38.int_value,
           ppscfv39.int_value,
           ppscfv40.int_value,
           lov40.name,
           ppscfv41.text_value,
           d.unapproved_zip_code_adder,
           ppscfv42.int_array_value,
           ppscfv43.int_array_value,
           pcfv25.int_value,
           pcfv23.int_array_value,
           ppscfv45.numeric_value,
           p.company_process_id,
           pcfv24.numeric_value,
           (ppscfv46.json_value ->> 'system_size_ac')::numeric                 as system_size_ac,
           (ppscfv47.json_value -> 'arrays' -> 0 -> 'module' ->> 'name')::text as panel_model,
           pcfv_48.boolean_value,
           pcfv26.boolean_value,
           pcfv28.numeric_value,
           pcfv29.numeric_value,
           pcfv70.int_value,
           ppscfv90.json_value,--prodction
           ppscfv91.json_value,--materials
           ppscfv92.json_value--panel
    from brs.proposal prop
           inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
           inner join flow.project p on pps.project_id = p.id
           inner join brs.project_details d on d.project_id = p.id
           inner join flow.contact c on p.contact_id = c.id
           inner join flow.company_state cs on p.company_state_id = cs.id
           inner join flow.state s on cs.state_id = s.id
           left join brs.proposal_custom_field_value pcfv3 on prop.id = pcfv3.proposal_id and
                                                              pcfv3.custom_field_group_assignment_id = 169
           left join brs.proposal_custom_field_value pcfv4 on prop.id = pcfv4.proposal_id and
                                                              pcfv4.custom_field_group_assignment_id = 134
           left join brs.proposal_custom_field_value pcfv5 on prop.id = pcfv5.proposal_id and
                                                              pcfv5.custom_field_group_assignment_id = 147
           left join brs.proposal_custom_field_value pcfv6 on prop.id = pcfv6.proposal_id and
                                                              pcfv6.custom_field_group_assignment_id = 165
           left join brs.list_of_value lov6 on lov6.id = pcfv6.int_value
           left join brs.proposal_custom_field_value pcfv7 on prop.id = pcfv7.proposal_id and
                                                              pcfv7.custom_field_group_assignment_id = 167
           left join flow.list_of_value lov on lov.id = pcfv5.int_value
           left join brs.proposal_custom_field_value pcfv8 on prop.id = pcfv8.proposal_id and
                                                              pcfv8.custom_field_group_assignment_id = 200
           left join brs.list_of_value lov2 on lov2.id = pcfv8.int_value
           left join brs.proposal_custom_field_value pcfv10 on prop.id = pcfv10.proposal_id and
                                                               pcfv10.custom_field_group_assignment_id = 201
           left join brs.proposal_custom_field_value pcfv11 on prop.id = pcfv11.proposal_id and
                                                               pcfv11.custom_field_group_assignment_id = 202
           left join brs.proposal_custom_field_value pcfv12 on prop.id = pcfv12.proposal_id and
                                                               pcfv12.custom_field_group_assignment_id = 203
           left join brs.proposal_custom_field_value pcfv13 on prop.id = pcfv13.proposal_id and
                                                               pcfv13.custom_field_group_assignment_id = 204
           left join brs.proposal_custom_field_value pcfv14 on prop.id = pcfv14.proposal_id and
                                                               pcfv14.custom_field_group_assignment_id = 205
           left join brs.proposal_custom_field_value pcfv15 on prop.id = pcfv15.proposal_id and
                                                               pcfv15.custom_field_group_assignment_id = 206
           left join brs.proposal_custom_field_value pcfv16 on prop.id = pcfv16.proposal_id and
                                                               pcfv16.custom_field_group_assignment_id = 389
           left join brs.proposal_custom_field_value pcfv17 on prop.id = pcfv17.proposal_id and
                                                               pcfv17.custom_field_group_assignment_id = 155
           left join brs.proposal_custom_field_value pcfv18 on prop.id = pcfv18.proposal_id and
                                                               pcfv18.custom_field_group_assignment_id = 447
           left join brs.proposal_custom_field_value pcfv19 on prop.id = pcfv19.proposal_id and
                                                               pcfv19.custom_field_group_assignment_id = 454
           left join brs.proposal_custom_field_value pcfv20 on prop.id = pcfv20.proposal_id and
                                                               pcfv20.custom_field_group_assignment_id = 455
           left join brs.proposal_custom_field_value pcfv21 on prop.id = pcfv21.proposal_id and
                                                               pcfv21.custom_field_group_assignment_id = 476
           left join brs.proposal_custom_field_value pcfv22 on prop.id = pcfv22.proposal_id and
                                                               pcfv22.custom_field_group_assignment_id = 480
           left join brs.proposal_custom_field_value pcfv23 on prop.id = pcfv23.proposal_id and
                                                               pcfv23.custom_field_group_assignment_id = 490
           left join brs.proposal_custom_field_value pcfv25 on prop.id = pcfv25.proposal_id and
                                                               pcfv25.custom_field_group_assignment_id = 581
           left join brs.proposal_custom_field_value pcfv26 on prop.id = pcfv26.proposal_id and
                                                               pcfv26.custom_field_group_assignment_id = 864
           left join brs.proposal_custom_field_value pcfv28 on prop.id = pcfv28.proposal_id and
                                                               pcfv28.custom_field_group_assignment_id = 866
           left join brs.proposal_custom_field_value pcfv29 on prop.id = pcfv29.proposal_id and
                                                               pcfv29.custom_field_group_assignment_id = 869 --stage --869 prod
           left join brs.proposal_custom_field_value pcfv70 on prop.id = pcfv70.proposal_id and
                                                               pcfv70.custom_field_group_assignment_id =  1317   -- prod 1317
           left join flow.project_process_step_custom_field_value ppscfv30
                     on pps.id = ppscfv30.project_process_step_id and
                        ppscfv30.custom_field_group_assignment_id = 22573
           left join flow.project_process_step_custom_field_value ppscfv31
                     on ppscfv31.project_process_step_id = pps.id and
                        ppscfv31.custom_field_group_assignment_id = 22563
           left join flow.project_process_step_custom_field_value ppscfv32
                     on ppscfv32.project_process_step_id = pps.id and
                        ppscfv32.custom_field_group_assignment_id = 22561
           left join flow.project_process_step_custom_field_value ppscfv33
                     on ppscfv33.project_process_step_id = pps.id and
                        ppscfv33.custom_field_group_assignment_id = 22675
           left join flow.project_process_step_custom_field_value ppscfv34
                     on ppscfv34.project_process_step_id = pps.id and
                        ppscfv34.custom_field_group_assignment_id = 22564
           left join flow.list_of_value lov34 on lov34.id = ppscfv34.int_value
           left join flow.project_process_step_custom_field_value ppscfv36
                     on ppscfv36.project_process_step_id = pps.id and
                        ppscfv36.custom_field_group_assignment_id = 22682
           left join flow.project_process_step_custom_field_value ppscfv90
                     on ppscfv90.project_process_step_id = pps.id and
                        ppscfv90.custom_field_group_assignment_id = 31564--solargraf production
           left join flow.project_process_step_custom_field_value ppscfv91
                     on ppscfv91.project_process_step_id = pps.id and
                        ppscfv91.custom_field_group_assignment_id = 31562--solargraf materials
           left join flow.project_process_step_custom_field_value ppscfv92
                     on ppscfv92.project_process_step_id = pps.id and
                        ppscfv92.custom_field_group_assignment_id = 31563--solargraf panel
           left join flow.project_process_step_custom_field_value ppscfv37
                     on ppscfv37.project_process_step_id = pps.id and
                        ppscfv37.custom_field_group_assignment_id = 22566
           left join flow.project_process_step_custom_field_value ppscfv38
                     on ppscfv38.project_process_step_id = pps.id and
                        ppscfv38.custom_field_group_assignment_id = 22567
           left join flow.project_process_step_custom_field_value ppscfv39
                     on ppscfv39.project_process_step_id = pps.id and
                        ppscfv39.custom_field_group_assignment_id = 22562
           left join flow.project_process_step_custom_field_value ppscfv40
                     on ppscfv40.project_process_step_id = pps.id and
                        ppscfv40.custom_field_group_assignment_id = 22565
           left join flow.list_of_value lov40 on lov40.id = ppscfv40.int_value
           left join flow.project_process_step_custom_field_value ppscfv41
                     on ppscfv41.project_process_step_id = pps.id and
                        ppscfv41.custom_field_group_assignment_id = 22560
           left join flow.project_process_step_custom_field_value ppscfv42
                     on ppscfv42.project_process_step_id = pps.id and
                        ppscfv42.custom_field_group_assignment_id = 25023
           left join flow.project_process_step_custom_field_value ppscfv43
                     on ppscfv43.project_process_step_id = pps.id and
                        ppscfv43.custom_field_group_assignment_id = 25981
      -- 45 = adder amount
           left join flow.project_process_step_custom_field_value ppscfv45
                     on ppscfv45.project_process_step_id = pps.id and
                        ppscfv45.custom_field_group_assignment_id = 26217
           left join flow.project_process_step_custom_field_value ppscfv35
                     on ppscfv35.project_process_step_id = pps.id and
                        ppscfv35.custom_field_group_assignment_id = 23802
           left join brs.feat_db_utility utility35 on utility35.id = ppscfv35.int_value
           left join brs.proposal_custom_field_value pcfv24 on prop.id = pcfv24.proposal_id and
                                                               pcfv24.custom_field_group_assignment_id = 517
           left join flow.project_process_step_custom_field_value ppscfv46
                     on ppscfv46.project_process_step_id = pps.id and
                        ppscfv46.custom_field_group_assignment_id = 22682
           left join flow.project_process_step_custom_field_value ppscfv47
                     on ppscfv47.project_process_step_id = pps.id and
                        ppscfv47.custom_field_group_assignment_id = 22682
           left join flow.project_custom_field_value pcfv_48 on pcfv_48.project_id = p.id and
                                                                pcfv_48.custom_field_group_assignment_id = 27524

    where prop.id = p_proposal_id;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
