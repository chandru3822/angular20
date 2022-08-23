drop function if exists brs.rpt_closer_funnel_appts_created_pipeline(p_custom_start_date date,
                                                                     p_custom_end_date date,
                                                                     p_brs_provided_source_ids bigint[],
                                                                     p_self_gen_source_ids bigint[]);
CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appts_created_pipeline(p_custom_start_date date,
                                                                        p_custom_end_date date,
                                                                        p_brs_provided_source_ids bigint[],
                                                                        p_self_gen_source_ids bigint[])
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
BEGIN

  RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
               from (
                      select id, name, display_order, today_count, week_to_date_count, custom_date_range_count
                      from (
                             with project_data as (
                               select pd.project_created_date,
                                      pd.source
                               from brs.project_details pd
                                      --we dont use anything from these joins but the drilldowns do inner joins so we need to do them also to avoid number mismatches
                                      inner join flow.user_position up on up.id = pd.closer_user_position_id
                                      inner join flow.org o on o.id = up.org_id
                               where pd.company_id = 3
                                 and pd.closer_appointment_start is not null
                                 and pd.source is not null
                                 --pre-filter the data as the subsets will require the source to be in one of these arrays
                                 -- or be empty
                                 and ((pd.source = any (p_brs_provided_source_ids) or
                                       pd.source = any (p_self_gen_source_ids))
                                   OR pd.source is null)
                                 and (pd.project_created_date :: DATE between p_custom_start_date and p_custom_end_date)
                                  OR (pd.project_created_date::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE)
                             )
                             select id,
                                    name,
                                    display_order,
                                    (select count(1)
                                     from project_data pd
                                     where
                                         ((pd.project_created_date at time zone 'UTC') at time zone 'US/Mountain') :: date =
                                         (now() at time zone 'US/Mountain')::date
                                       and case
                                             when f.use_brs_sources is false and f.use_self_gen_sources is false
                                               then pd.source is null
                                             when f.use_brs_sources and f.use_self_gen_sources
                                               then (pd.source = any (p_brs_provided_source_ids) OR
                                                     pd.source = any (p_self_gen_source_ids) OR pd.source is null)
                                             when f.use_brs_sources
                                               then pd.source = any (p_brs_provided_source_ids)
                                             when f.use_self_gen_sources
                                               then pd.source = any (p_self_gen_source_ids) end) as today_count,
                                    (select count(1)
                                     from project_data pd
                                     where ((pd.project_created_date at time zone 'UTC') at time zone 'US/Mountain') :: date between
                                       ((date_trunc('week', now() at time zone 'US/Mountain'))::date) and (now() at time zone 'US/Mountain')::date
                                       and case
                                             when f.use_brs_sources is false and f.use_self_gen_sources is false
                                               then pd.source is null
                                             when f.use_brs_sources and f.use_self_gen_sources
                                               then (pd.source = any (p_brs_provided_source_ids) OR
                                                     pd.source = any (p_self_gen_source_ids) OR pd.source is null)
                                             when f.use_brs_sources
                                               then pd.source = any (p_brs_provided_source_ids)
                                             when f.use_self_gen_sources
                                               then pd.source = any (p_self_gen_source_ids) end) as week_to_date_count,
                                    (select count(1)
                                     from project_data pd
                                     where ((pd.project_created_date at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                       and case
                                             when f.use_brs_sources is false and f.use_self_gen_sources is false
                                               then pd.source is null
                                             when f.use_brs_sources and f.use_self_gen_sources
                                               then (pd.source = any (p_brs_provided_source_ids) OR
                                                     pd.source = any (p_self_gen_source_ids) OR pd.source is null)
                                             when f.use_brs_sources
                                               then pd.source = any (p_brs_provided_source_ids)
                                             when f.use_self_gen_sources
                                               then pd.source = any (p_self_gen_source_ids) end) as custom_date_range_count
                             from brs.funnel f
                             where archived is false
                               and funnel_type_id = 2
                           ) as row_counts
                      order by display_order
                    ) as funnel_rows;

END
$function$
