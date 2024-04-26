drop procedure if exists brs.change_to_redline(
  p_project_id bigint);
CREATE OR REPLACE procedure brs.change_to_redline(
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
  v_df_proposal_id                  bigint;
  v_booking_proposal_id             bigint;
BEGIN
  v_df_proposal_id = null;
  v_booking_proposal_id = null;

  select v.int_value
  into v_df_proposal_id
  from flow.project_process_step p
         inner join flow.project_process_step_custom_field_value v on v.project_process_step_id = p.id and
                                                                      v.custom_field_group_assignment_id = 19449
  where p.project_id = p_project_id
    and p.main is true
    and p.process_step_id = 3355;

  if v_df_proposal_id is null then
    select v.int_value
    into v_booking_proposal_id
    from flow.project_process_step p
           inner join flow.project_process_step_custom_field_value v on v.project_process_step_id = p.id and
                                                                        v.custom_field_group_assignment_id = 1434
    where p.project_id = p_project_id
      and p.main is true
      and p.process_step_id = 4;
  end if;

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
                          order by proposal_group_uuid, custom_field_group_assignment_id, id desc),
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
  select (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 380)') ->> 'value')::numeric as red_line_funding_amount,
         (jsonb_path_query(row, '$.fields[*] ? (@.fieldId == 91)') ->> 'value')::numeric  as minimum_funding_amount_per_watt
  into v_red_line_funding_amount,v_minimum_funding_amount_per_watt
  from grouped_rows
  where jsonb_path_match(row, 'exists($.fields[*] ? (@.intValue == $field))',
                         jsonb_build_object('field', v_utility_company_id));

  v_markup = v_minimum_funding_amount_per_watt - v_red_line_funding_amount;

  if v_source_id != 523 then
    v_closer_commission_amount = v_markup * .68;
  elsif v_source_id = 523 then
    v_closer_commission_amount = (v_markup + .50) * .68;
  end if;

  if v_df_proposal_id is not null then
    perform flow.set_pps_cfv(p_project_id, 2356764, 27107, 24102::text, true);
    if v_closer_commission_amount is not null then
      perform flow.set_pps_cfv(p_project_id, 2356764, 26166, v_closer_commission_amount::text, true);
    end if;
  end if;

  update brs.proposal_log_history plh
  set commission_strategy_id    = 24102,
      desired_commission_amount = v_closer_commission_amount,
      date_modified = now()
  where case
          when p_update_all_plh is true then
            plh.project_id = p_project_id
          when v_df_proposal_id is not null then
            plh.id = v_df_proposal_id
          when v_booking_proposal_id is not null then
            plh.id = v_booking_proposal_id end;

  update brs.project_commission pc
  set commission_plan_id = 63
  where project_id = p_project_id;

  update brs.financial_details fd
  set commission_plan_id     = 63,
      commission_plan        = 'Redline Commission',
      commission_plan_status = 'ACTIVE',
      date_modified = now()
  where project_id = p_project_id;

  call brs.reset_financial_details(p_project_id);

  perform flow.set_project_cfv(p_project_id, 2356764, 24819, true::text, true);


END
$BODY$
  LANGUAGE plpgsql;


