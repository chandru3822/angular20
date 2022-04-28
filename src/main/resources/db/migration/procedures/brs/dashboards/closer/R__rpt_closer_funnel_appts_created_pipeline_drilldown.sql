CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appts_created_pipeline_drilldown(p_start_date date, p_end_date date,
                                                                                  p_funnel_id integer,
                                                                                  p_source_ids integer[])
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

END
$function$
