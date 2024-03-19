drop function if exists brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date,
                                                                               p_funnel_id bigint,
                                                                               p_source_ids bigint[],
                                                                               p_run_by_id bigint);
drop function if exists brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date,
                                                                               p_funnel_id bigint,
                                                                               p_source_ids bigint[]);
CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date,
                                                                                  p_funnel_id bigint,
                                                                                  p_source_ids bigint[])
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_show_no_source  boolean;
  v_show_everything boolean;
BEGIN

  select (f.use_brs_sources is false AND f.use_self_gen_sources is false),
         (f.use_brs_sources is true AND f.use_self_gen_sources is true)
  into v_show_no_source, v_show_everything
  from brs.funnel f
  where f.id = p_funnel_id;


  case
    when p_funnel_id = 34 then RETURN QUERY
      select array_to_json(array_agg(row_to_json(funnel_rows)))
      from (select concat(c.first_name,' ',c.last_name)                    customer_name,
                   c.id,
                   lov.name as source_name,
                   concat(u2.first_name,' ',u2.last_name) as contact_owner,
                   s.state,
                   c.date_created
            from flow.contact c
             inner join flow.contact_custom_field_value ccfv on ccfv.contact_id = c.id and
                                                                custom_field_group_assignment_id = 395 and
                                                                ccfv.int_value = any(p_source_ids)
            inner join flow.list_of_value lov on lov.id = ccfv.int_value
            left join flow.user_position u on u.id = c.owner_user_position_id
            left join flow."user" u2 on u2.id = u.user_id
            left join flow.company_state cs on cs.id = c.company_state_id
            left join flow.state s on s.id = cs.state_id
            where ((c.date_created at time zone 'UTC') at time zone
                   'US/Mountain')::date between p_start_date and p_end_date
            order by customer_name, c.date_created) as funnel_rows;
    else return query
      select array_to_json(array_agg(row_to_json(funnel_rows)))
      from (select pd.closer_name                 as owner_name,
                   o.org_name                        office,
                   pd.project_state_abbreviation     state,
                   pd.company_project_status_type as status_type,
                   pd.contact_name                   customer_name,
                   pd.contact_id,
                   pd.project_id,
                   pd.source_name,
                   pd.system_size,
                   pd.primary_financier_name         financier,
                   pd.closer_appointment_start       appointment_date,
                   pd.cancelled_date,
                   pd.project_created_date        as date_created
            from brs.project_details pd
                   inner join flow.user_position up on up.id = pd.closer_user_position_id
                   inner join flow.org o on o.id = up.org_id
            where ((pd.first_time_appointment_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
              and pd.closer_appointment_start is not null
              and pd.closer_user_id is not null
              and case
                    when v_show_no_source then pd.source is null
                    when v_show_everything then (pd.source is null OR pd.source = any (p_source_ids))
                    else pd.source = any (p_source_ids) end
            order by owner_name, pd.project_created_date) as funnel_rows;

    end case;
END
$function$
