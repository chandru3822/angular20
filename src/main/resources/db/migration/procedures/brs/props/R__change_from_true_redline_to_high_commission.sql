drop procedure if exists brs.change_from_true_redline_to_high_commission(
  p_project_id bigint, boolean);
CREATE OR REPLACE procedure brs.change_from_true_redline_to_high_commission(
  p_project_id bigint,
  p_update_all_plh boolean default false)
AS
$BODY$
declare
  v_utility_company_id              bigint;
  v_utility_company                 varchar;
  v_red_line_funding_amount         numeric;
  v_minimum_funding_amount_per_watt numeric;
  v_source_id                       bigint;
  v_markup                          numeric;
  v_closer_commission_amount        numeric;
  v_df_pps_id                       bigint;
  v_booking_pps_id                  bigint;
  v_pcfv_commission_strategy_id     bigint;
  v_pcfv_desired_commission_id      bigint;
  x                                 record;
  v_df_cs_id                        bigint;
  v_df_dca_id                       bigint;
  v_booking_cs_id                   bigint;
  v_booking_dca_id                  bigint;
  v_plh_id                          bigint;
BEGIN

  select pd.utility_company,
         pd.utility_company_name,
         pd.source
  into
    v_utility_company_id,
    v_utility_company,
    v_source_id
  from brs.project_details pd
  where pd.project_id = p_project_id;


  with version_values as (select distinct on ( proposal_group_uuid, custom_field_group_assignment_id ) id,
                                                                                                       custom_field_group_assignment_id,
                                                                                                       proposal_group_uuid,
                                                                                                       proposal_version_id,
                                                                                                       value,
                                                                                                       field_id,
                                                                                                       field_code,
                                                                                                       modified_by_id,
                                                                                                       modified_by,
                                                                                                       date_modified
                          from brs.proposal_version_custom_field_value_vw
                          where proposal_version_id <= (select proposal_version_id
                                                        from brs.primary_company_proposal_version
                                                        where company_id = 3
                                                        limit 1)
                            and object_code = 'PROPOSAL_PRICING'
                            and proposal_group_uuid not in (select distinct proposal_group_uuid
                                                            from brs.proposal_version_custom_field_group
                                                            where archived is not null
                                                              and proposal_version_id <= (select proposal_version_id
                                                                                          from brs.primary_company_proposal_version
                                                                                          where company_id = 3
                                                                                          limit 1))
                          order by proposal_group_uuid, custom_field_group_assignment_id, date_modified desc),
       grouped_rows as (select jsonb_build_object('pk', proposal_group_uuid,
                                                  'fields',
                                                  array_to_json(array_agg(jsonb_strip_nulls(
                                                    jsonb_build_object('fieldId', vv.field_id,
                                                                       'flowCustomFieldId',
                                                                       cf.flow_custom_field_id) || vv.value)))
                               ) as row
                        from version_values vv
                               inner join brs.custom_field cf on cf.id = vv.field_id
                        group by proposal_group_uuid)
  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 380)') ->> 'value')::numeric as red_line_funding_amount
  into v_red_line_funding_amount
  from grouped_rows
  where jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $field))',
                         jsonb_build_object('field', v_utility_company_id));


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
      select loan_fundingw, h.id
      into v_minimum_funding_amount_per_watt,v_plh_id
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
        and p.process_step_id = 3355;


      select p.id
      into v_booking_pps_id
      from flow.project_process_step p
             inner join flow.project_process_step_custom_field_value v on v.project_process_step_id = p.id and
                                                                          v.custom_field_group_assignment_id = 1434
      where p.project_id = p_project_id
        and v.int_value = v_plh_id
        and p.process_step_id = 4;

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

      v_markup = v_minimum_funding_amount_per_watt - v_red_line_funding_amount;

      if v_source_id != 523 then
        v_closer_commission_amount = v_markup * .68 ;
      elsif v_source_id = 523 then
        v_closer_commission_amount = ((v_markup + .50) * .68) ;
      end if;

      v_closer_commission_amount = round(v_closer_commission_amount, 3);

      if v_df_pps_id is not null then
        select ppscfv.id
        into v_df_cs_id
        from flow.project_process_step s
               inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = s.id
        where ppscfv.custom_field_group_assignment_id = 27107
          and s.id = v_df_pps_id;

        select ppscfv.id
        into v_df_dca_id
        from flow.project_process_step s
               inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = s.id
        where ppscfv.custom_field_group_assignment_id = 26166
          and s.id = v_df_pps_id;

        if v_df_cs_id is not null then
          update flow.project_process_step_custom_field_value
          set int_value = 24102::bigint
          where id = v_df_cs_id;
        else
          insert into flow.project_process_step_custom_field_value(project_process_step_id,
                                                                   custom_field_group_assignment_id, int_value,
                                                                   date_created, date_modified, created_by_id,
                                                                   modified_by_id)
          values (v_df_pps_id, 27107, 24102::bigint, now(), now(), 99999999, 99999999);
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


      if v_booking_pps_id is not null then
        select ppscfv.id
        into v_booking_cs_id
        from flow.project_process_step s
               inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = s.id
        where ppscfv.custom_field_group_assignment_id = 27105
          and s.id = v_booking_pps_id;

        select ppscfv.id
        into v_booking_dca_id
        from flow.project_process_step s
               inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = s.id
        where ppscfv.custom_field_group_assignment_id = 26943
          and s.id = v_booking_pps_id;

        if v_booking_cs_id is not null then
          update flow.project_process_step_custom_field_value
          set int_value = 24102::bigint
          where id = v_booking_cs_id;
        else
          insert into flow.project_process_step_custom_field_value(project_process_step_id,
                                                                   custom_field_group_assignment_id, int_value,
                                                                   date_created, date_modified, created_by_id,
                                                                   modified_by_id)
          values (v_booking_pps_id, 27105, 24102::bigint, now(), now(), 99999999, 99999999);
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

      update brs.proposal_log_history plh
      set commission_strategy_id    = 24102,
          desired_commission_amount = v_closer_commission_amount,
          date_modified             = now()
      where plh.id = v_plh_id;

      if v_pcfv_commission_strategy_id is not null then
        update brs.proposal_custom_field_value pcfv
        set int_value = 24102
        where id = v_pcfv_commission_strategy_id;
      else
        insert into brs.proposal_custom_field_value(proposal_id, custom_field_group_assignment_id, int_value,
                                                    date_created, date_modified, created_by_id, modified_by_id)
        values (x.id, 581, 24102, now(), now(), 99999999, 99999999);
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

    end loop;

  update brs.project_commission pc
  set commission_plan_id = 63
  where project_id = p_project_id;

  update brs.financial_details fd
  set commission_plan_id     = 63,
      commission_plan        = 'Redline Commission',
      commission_plan_status = 'ACTIVE',
      date_modified          = now(),
      commission_strategy  = 24102,
      commission_strategy_name = 'High Commission'
  where project_id = p_project_id;

  call brs.reset_financial_details(p_project_id);

  perform flow.set_project_cfv(p_project_id, 2356764, 24819, true::text, true);

END
$BODY$
  LANGUAGE plpgsql;


