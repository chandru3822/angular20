drop function if exists brs.get_final_designs_completed_drilldown(p_user_id bigint, p_quarter bigint);
CREATE OR REPLACE FUNCTION brs.get_final_designs_completed_drilldown(p_user_id bigint, p_quarter bigint)
  RETURNS SETOF json AS
$BODY$
declare
  v_start_date date;
  v_end_date date;
  v_year bigint;
BEGIN
  select extract('year' from now())::bigint
  into v_year;

  case when p_quarter = 1 then
    v_start_date := (v_year || '-01-01')::date;
    v_end_date := (v_year || '-03-31')::date;
  when p_quarter = 2 then
    v_start_date := (v_year || '-04-01')::date;
    v_end_date := (v_year || '-06-30')::date;
  when p_quarter = 3 then
    v_start_date := (v_year || '-07-01')::date;
    v_end_date := (v_year || '-09-30')::date;
  else
    v_start_date := (v_year || '-10-01')::date;
    v_end_date := (v_year || '-12-31')::date;
  end case;

  RETURN QUERY select array_to_json(array_agg(row_to_json(sub_rows)))
    from (
      select pd.contact_name as customer_name,
             pd.project_id as id,
             pd.source_name,
             pd.closer_name as owner_name,
             pd.system_size,
             pd.final_design_complete_date,
             --requirements for self_gen as defined by BR
                    -- -- Lead Source = Closer Gen || Events - Closer Gen
                    -- -- Referral = True
                    -- -- Referred By = False
                    -- -- Referral Generation Representative = False
             case when pd.source in (523, 524, 530, 20016) AND
                       ccfv_referral.boolean_value is true AND
                       coalesce(ccfv_referred_by.text_value, '') = '' AND
                       ccfv_ref_gen_rep.int_value is null
                       then true else false end as self_gen
      from brs.project_details pd
        left join flow.contact_custom_field_value ccfv_referral on ccfv_referral.contact_id = pd.contact_id and ccfv_referral.custom_field_group_assignment_id = 19106 -- Referral field - boolean
        left join flow.contact_custom_field_value ccfv_referred_by on ccfv_referred_by.contact_id = pd.contact_id and ccfv_referred_by.custom_field_group_assignment_id = 997 -- Referral by field - text
        left join flow.contact_custom_field_value ccfv_ref_gen_rep on ccfv_ref_gen_rep.contact_id = pd.contact_id and ccfv_ref_gen_rep.custom_field_group_assignment_id = 19178 -- Referral Generation Representative field - system list (bigint)
      where pd.final_design_complete_date is not null
        and pd.final_design_complete_date::date between v_start_date and v_end_date
        and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > v_end_date))
        and (pd.company_project_status_type_id is null or pd.company_project_status_type_id != 3)
        and pd.closer_user_id = p_user_id
        and pd.company_id = 3
      group by customer_name, pd.project_id, pd.source_name, owner_name, pd.system_size,
               pd.final_design_complete_date, pd.source, ccfv_referral.boolean_value,
               ccfv_referred_by.text_value, ccfv_ref_gen_rep.int_value
      order by customer_name
    ) as sub_rows;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Get Final Designs Completed Drilldown', 'p_user_id: ' || p_user_id ||
                                                     ' p_quarter: ' || p_quarter,
            p_user_id);

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;
