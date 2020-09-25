CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard(p_custom_start_date date, p_custom_end_date date, p_base_expectation numeric, p_user_ids integer[], p_org_ids integer[])
    RETURNS SETOF json
    LANGUAGE plpgsql
AS $function$
declare
    v_whole_company boolean;
BEGIN
    select p_user_ids && Array[-1] into v_whole_company;
    if v_whole_company then
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
		from (
            --Appointments Occurred
			with setter_funnel_1 as (
                select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
				     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
				     and pd.closer_appointment_start::date = (now() at time zone 'US/Mountain')::date) as today_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
				     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
				     and pd.closer_appointment_start::date = (now() at time zone 'US/Mountain')::date - 1) as yesterday_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
				     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
				     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 7
				     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 1) as seven_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
				     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
				     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 14
				     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 7) as prev_seven_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
				     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
				     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 30
				     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 1) as thirty_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
				     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
				     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 60
				     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 30) as prev_thirty_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
				     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
				     and pd.closer_appointment_start::date between p_custom_start_date and p_custom_end_date) as custom_date_range_count
				from brs.setter_funnel
				where id = 1
            ),

            --Appointments Pitched
            setter_funnel_2 as (
                select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
				     ) as today_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
				     and pd.closer_appointment_start::date = (now() at time zone 'US/Mountain')::date - 1) as yesterday_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
				     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 7
				     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 1) as seven_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
				     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 14
				     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 7) as prev_seven_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
				     and pd.closer_appointment_start::date >= ((now() at time zone 'US/Mountain')::date) - 30
				     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 1) as thirty_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
				     and pd.closer_appointment_start::date >= ((now() at time zone 'US/Mountain')::date) - 60
				     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 30) as prev_thirty_day_count,
				(select count(1)
				 from brs.project_details pd
				 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
				     and pd.closer_appointment_start::date between p_custom_start_date and p_custom_end_date) as custom_date_range_count
				from brs.setter_funnel
				where id = 2
            ),

            --Appointments Created
            setter_funnel_3 as (
                select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
				(select count(1)
				 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
				 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
				     and p.date_created::date = (now() at time zone 'US/Mountain')::date) as today_day_count,
				(select count(1)
				 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
				 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
				     and p.date_created::date = (now() at time zone 'US/Mountain')::date - 1) as yesterday_day_count,
				(select count(1)
				 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
				 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
				     and p.date_created::date >= (now() at time zone 'US/Mountain')::date - 7
				     and p.date_created::date <= (now() at time zone 'US/Mountain')::date - 1) as seven_day_count,
				(select count(1)
				 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
				 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
				     and p.date_created::date >= (now() at time zone 'US/Mountain')::date - 14
				     and p.date_created::date <= (now() at time zone 'US/Mountain')::date - 7) as prev_seven_day_count,
				(select count(1)
				 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
				 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
				     and p.date_created::date >= (now() at time zone 'US/Mountain')::date - 30
				     and p.date_created::date <= (now() at time zone 'US/Mountain')::date - 1) as thirty_day_count,
				(select count(1)
				 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
				 where p.date_created::date >= (now() at time zone 'US/Mountain')::date - 60
				     and pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
				     and p.date_created::date <= (now() at time zone 'US/Mountain')::date - 30) as prev_thirty_day_count,
				(select count(1)
				 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
				 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
				     and p.date_created::date between p_custom_start_date and p_custom_end_date) as custom_date_range_count
				from brs.setter_funnel
				where id = 3
            )

            select id,
                   name,
                   ratio,
                   expectation,
                   display_order,
                   today_day_count,
                   yesterday_day_count,
                   case when yesterday_day_count = 0 then 0
                       else cast(cast(today_day_count - yesterday_day_count as numeric(10,2)) / yesterday_day_count as numeric(6,2)) * 100
                       end as today_percent,
                   seven_day_count,
                   prev_seven_day_count,
                   case when prev_seven_day_count = 0 then 0
                       else cast(cast(seven_day_count - prev_seven_day_count as numeric(10,2)) / prev_seven_day_count as numeric(6,2)) * 100
                       end as seven_percent,
                   thirty_day_count,
                   prev_thirty_day_count,
                   case when prev_thirty_day_count = 0 then 0
                       else cast(cast(thirty_day_count-prev_thirty_day_count as numeric(10,2)) / prev_thirty_day_count as numeric(6,2)) * 100
                       end as thirty_day_percent,
                   custom_date_range_count
			from (
			    select * from setter_funnel_1
			    union all
			    select * from setter_funnel_2
			    union all
			    select * from setter_funnel_3
            ) as row_counts order by display_order
		) as funnel_rows;
    else
	    RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
        from (
            --Appointments Occurred
		    with setter_funnel_1 as (
                select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
    			(select count(1)
    			 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
    			 where pd.source = 6 --Setter Gen
    			     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
    			     and pd.closer_appointment_start is not null
    			     and pd.closer_appointment_start::date = (now() at time zone 'US/Mountain')::date
                     and u.id is not null
    			     and Array[u.id]::integer[] && p_user_ids
    			     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as today_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
                     and pd.closer_appointment_start::date = (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as yesterday_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
                     and pd.closer_appointment_start::date >= ((now() at time zone 'US/Mountain')::date ) - 7
                     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as seven_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
                     and pd.closer_appointment_start::date >= ((now() at time zone 'US/Mountain')::date ) - 14
                     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 7
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as prev_seven_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
                     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 30
                     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as thirty_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
                     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 60
                     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 30
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as prev_thirty_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                     and pd.closer_appointment_start is not null
                     and pd.closer_appointment_start::date between p_custom_start_date and p_custom_end_date
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as custom_date_range_count
                from brs.setter_funnel
                where id = 1
            ),

            --Appointments Pitched
            setter_funnel_2 as (
                select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                     and pd.closer_appointment_start::date = (now() at time zone 'US/Mountain')::date
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as today_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                     and pd.closer_appointment_start::date = (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as yesterday_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 7
                     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as seven_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 14
                     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 7
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as prev_seven_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 30
                     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as thirty_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                     and pd.closer_appointment_start::date >= (now() at time zone 'US/Mountain')::date - 60
                     and pd.closer_appointment_start::date <= (now() at time zone 'US/Mountain')::date - 30
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as prev_thirty_day_count,
                (select count(1)
                 from brs.project_details pd
                     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and pd.closer_appointment_outcome in (2,3) --(Pitched, Missed)
                     and pd.closer_appointment_start::date between p_custom_start_date and p_custom_end_date
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as custom_date_range_count
                from brs.setter_funnel
                where id = 2
            ),

            --Appointments Created
            setter_funnel_3 as (
                select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
                (select count(1)
                 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
                     and p.date_created::date = (now() at time zone 'US/Mountain')::date
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as today_day_count,
                (select count(1)
                 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
                     and p.date_created::date = (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as yesterday_day_count,
                (select count(1)
                 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
                     and p.date_created::date >= ((now() at time zone 'US/Mountain')::date) - 7
                     and p.date_created::date <= (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as seven_day_count,
                (select count(1)
                 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
                     and p.date_created::date >= ((now() at time zone 'US/Mountain')::date) - 14
                     and p.date_created::date <= (now() at time zone 'US/Mountain')::date - 7
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as prev_seven_day_count,
                (select count(1)
                 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
                     and p.date_created::date >= ((now() at time zone 'US/Mountain')::date) - 30
                     and p.date_created::date <= (now() at time zone 'US/Mountain')::date - 1
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as thirty_day_count,
                (select count(1)
                 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
                     and p.date_created::date >= ((now() at time zone 'US/Mountain')::date) - 60
                     and p.date_created::date <= (now() at time zone 'US/Mountain')::date - 30
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as prev_thirty_day_count,
                (select count(1)
                 from brs.project_details pd
				     inner join flow.project p on p.id = pd.project_id
                     inner join flow.contact c on c.id = p.contact_id
                     inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                     inner join flow.user u on u.id = upv.user_id
                 where pd.source = 6 --Setter Gen
                     and coalesce(pd.closer_appointment_outcome, '') != 4 --Cancelled
                     and p.date_created::date between p_custom_start_date and p_custom_end_date
                     and u.id is not null
                     and Array[u.id]::integer[] && p_user_ids
                     and Array[u.id]::integer[] && brs.limit_by_org_for_setters(Array[u.id]::integer[],p_org_ids,p.date_created::date)) as custom_date_range_count
                from brs.setter_funnel
                where id = 3
            )

            select id,
                   name,
                   ratio,
                   expectation,
                   display_order,
                   today_day_count,
                   yesterday_day_count,
                   case when yesterday_day_count = 0 then 0
                       else cast(cast(today_day_count - yesterday_day_count as numeric(10,2)) / yesterday_day_count as numeric(6,2)) * 100
                       end as today_percent,
                   seven_day_count,
                   prev_seven_day_count,
                   case when prev_seven_day_count = 0 then 0
                       else cast(cast(seven_day_count - prev_seven_day_count as numeric(10,2)) / prev_seven_day_count as numeric(6,2)) * 100
                       end as seven_percent,
                   thirty_day_count,
                   prev_thirty_day_count,
                   case when prev_thirty_day_count = 0 then 0
                       else cast(cast(thirty_day_count-prev_thirty_day_count as numeric(10,2)) / prev_thirty_day_count as numeric(6,2)) * 100
                       end as thirty_day_percent,
                   custom_date_range_count
            from (
                select * from setter_funnel_1
                union all
                select * from setter_funnel_2
                union all
                select * from setter_funnel_3
            ) as row_counts order by display_order
		) as funnel_rows;

    end if;

END
$function$
