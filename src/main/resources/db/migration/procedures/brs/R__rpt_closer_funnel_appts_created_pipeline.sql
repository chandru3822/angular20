CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appts_created_pipeline(p_custom_start_date date, p_custom_end_date date, p_brs_provided_source_ids integer[], p_self_gen_source_ids integer[])
	RETURNS SETOF json
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
        from (
            select id, name, display_order, today_count, week_to_date_count, custom_date_range_count
            from (
                select id, name, display_order,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date = (now() at time zone 'US/Mountain')::date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null and
                       Array[pd.source] <@ p_brs_provided_source_ids) as today_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date >= ((date_trunc('week', now() at time zone 'US/Mountain'))::date) and
                       p.date_created::date <= (now() at time zone 'US/Mountain')::date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null and
                       Array[pd.source] <@ p_brs_provided_source_ids) as week_to_date_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date between p_custom_start_date and p_custom_end_date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null and
                       Array[pd.source] <@ p_brs_provided_source_ids) as custom_date_range_count
                from brs.funnel
                where id = 12 --BRS-provided appointments created

                union all

                select id, name, display_order,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date = (now() at time zone 'US/Mountain')::date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null and
                       Array[pd.source] <@ p_self_gen_source_ids) as today_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date >= ((date_trunc('week', now() at time zone 'US/Mountain'))::date) and
                       p.date_created::date <= (now() at time zone 'US/Mountain')::date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null and
                       Array[pd.source] <@ p_self_gen_source_ids) as week_to_date_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date between p_custom_start_date and p_custom_end_date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null and
                       Array[pd.source] <@ p_self_gen_source_ids) as custom_date_range_count
                from brs.funnel
                where id = 13 --Self-gen appointments created

                union all

                select id, name, display_order,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date = (now() at time zone 'US/Mountain')::date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null) as today_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date >= ((date_trunc('week', now() at time zone 'US/Mountain'))::date) and
                       p.date_created::date <= (now() at time zone 'US/Mountain')::date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null) as week_to_date_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                 where p.date_created::date between p_custom_start_date and p_custom_end_date and
                       pd.closer_appointment_start is not null and
                       pd.source is not null) as custom_date_range_count
                from brs.funnel
                where id = 10 --Total Appointments Created
            ) as row_counts order by display_order
        ) as funnel_rows;

END
$function$
