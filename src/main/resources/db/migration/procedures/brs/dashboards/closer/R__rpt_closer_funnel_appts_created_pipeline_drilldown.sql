drop function if exists brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date,
                                                                               p_funnel_id bigint,
                                                                               p_source_ids bigint[],
                                                                               p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date,
                                                                                  p_funnel_id bigint,
                                                                                  p_source_ids bigint[],
                                                                                  p_run_by_id bigint)
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

  RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
               from (
                      select pd.closer_name                 as owner_name,
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
                      where ((pd.project_created_date at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                        and pd.closer_appointment_start is not null
                        and case
                              when v_show_no_source then pd.source is null
                              when v_show_everything then (pd.source is null OR pd.source = any (p_source_ids))
                              else pd.source = any (p_source_ids) end
                      order by owner_name, pd.project_created_date
                    ) as funnel_rows;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Closer Funnel Appointments Created Pipeline Drilldown Report',
                'p_start_date: ' || p_start_date ||
                ' p_end_date: ' || p_end_date ||
                ' p_funnel_id: ' || p_funnel_id ||
                ' p_source_ids: ' || p_source_ids ||
                ' p_run_by_id: ' || p_run_by_id,
            p_run_by_id);

END
$function$
