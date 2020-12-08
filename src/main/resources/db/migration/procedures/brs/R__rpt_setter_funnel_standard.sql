CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard(p_custom_start_date date, p_custom_end_date date, p_base_expectation numeric, p_user_ids integer[], p_org_ids integer[])
    RETURNS SETOF json
    LANGUAGE plpgsql
AS $function$
declare
    v_whole_company boolean;
BEGIN
    select -1 = any(p_user_ids) into v_whole_company;
    if v_whole_company then
        RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
		from (
        --Appointments Created
        with setter_funnel_3 as (
            select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
				    (select count(1)
				     from brs.project_details pd
				         inner join flow.project p on p.id = pd.project_id
				         inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
				     where pd.source = 525 --Setter Gen
                -- and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date) as today_day_count,
				    (select count(1)
				     from brs.project_details pd
				         inner join flow.project p on p.id = pd.project_id
				         inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
				     where pd.source = 525 --Setter Gen
              --   and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date - 1) as yesterday_day_count,
				    (select count(1)
				     from brs.project_details pd
				         inner join flow.project p on p.id = pd.project_id
				         inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
				     where pd.source = 525 --Setter Gen
               --  and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 7
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as seven_day_count,
				    (select count(1)
				     from brs.project_details pd
				         inner join flow.project p on p.id = pd.project_id
				         inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
				     where pd.source = 525 --Setter Gen
                -- and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 14
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 7) as prev_seven_day_count,
				    (select count(1)
				     from brs.project_details pd
				         inner join flow.project p on p.id = pd.project_id
				         inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
				     where pd.source = 525 --Setter Gen
               --  and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 30
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as thirty_day_count,
				    (select count(1)
				     from brs.project_details pd
				         inner join flow.project p on p.id = pd.project_id
				         inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
				     where ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 60
				         and pd.source = 525 --Setter Gen
               --  and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 30) as prev_thirty_day_count,
				    (select count(1)
				     from brs.project_details pd
				         inner join flow.project p on p.id = pd.project_id
				         inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
				     where pd.source = 525 --Setter Gen
                 --and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
				         and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date) as custom_date_range_count
				    from brs.setter_funnel
				    where id = 3
        ),

        --Appointments Occurred
  			setter_funnel_1 as (
            select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
  				       and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date) as today_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
  				       and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date - 1) as yesterday_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
  				       and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 7
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as seven_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
  				       and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 14
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 7) as prev_seven_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
  				       and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 30
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as thirty_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
  				       and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 60
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 30) as prev_thirty_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
  				       and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                 and pd.closer_appointment_start is not null
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date) as custom_date_range_count
  				  from brs.setter_funnel
  				  where id = 1
        ),

        --Appointments Pitched
        setter_funnel_2 as (
            select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
                 and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date) as today_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
                 and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date - 1) as yesterday_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
                 and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 7
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as seven_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
                 and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 14
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 7) as prev_seven_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
                 and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= ((now() at time zone 'US/Mountain')::date) - 30
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date) as thirty_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
                 and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= ((now() at time zone 'US/Mountain')::date) - 60
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 30) as prev_thirty_day_count,
  				  (select count(1)
  				   from brs.project_details pd
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
  				   where pd.source = 525 --Setter Gen
                 and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
  				       and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date) as custom_date_range_count
  				  from brs.setter_funnel
  				  where id = 2
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
                   else cast(cast(thirty_day_count - prev_thirty_day_count as numeric(10,2)) / prev_thirty_day_count as numeric(6,2)) * 100
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
                --Appointments Created
                with setter_funnel_3 as (
                    select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                             --   and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                and pd.closer_appointment_start is not null
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as today_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                         --       and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                and pd.closer_appointment_start is not null
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date - 1
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as yesterday_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                        --        and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                and pd.closer_appointment_start is not null
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= ((now() at time zone 'US/Mountain')::date) - 7
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as seven_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                          --      and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                and pd.closer_appointment_start is not null
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= ((now() at time zone 'US/Mountain')::date) - 14
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 7
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_seven_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                          --      and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                and pd.closer_appointment_start is not null
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= ((now() at time zone 'US/Mountain')::date) - 30
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as thirty_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                          --      and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                and pd.closer_appointment_start is not null
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= ((now() at time zone 'US/Mountain')::date) - 60
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 30
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_thirty_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                           --     and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                and pd.closer_appointment_start is not null
                                and ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as custom_date_range_count
                    from brs.setter_funnel
                    where id = 3
                ),

                --Appointments Occurred
		            setter_funnel_1 as (
                    select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
    			                 (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
    			                  where pd.source = 525 --Setter Gen
    			                      and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
    			                      and pd.closer_appointment_start is not null
    			                      and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date
    			                      and pd.setter_user_id = any(p_user_ids)
    			                      and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as today_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                                and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                and pd.closer_appointment_start is not null
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date - 1
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as yesterday_day_count,
                            (select count(1)
                             from brs.project_details pd
  				                       inner join flow.project p on p.id = pd.project_id
                                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                             where pd.source = 525 --Setter Gen
                                 and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                 and pd.closer_appointment_start is not null
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= ((now() at time zone 'US/Mountain')::date ) - 7
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                 and pd.setter_user_id = any(p_user_ids)
                                 and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as seven_day_count,
                            (select count(1)
                             from brs.project_details pd
  				                       inner join flow.project p on p.id = pd.project_id
                                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                             where pd.source = 525 --Setter Gen
                                 and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                 and pd.closer_appointment_start is not null
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= ((now() at time zone 'US/Mountain')::date ) - 14
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 7
                                 and pd.setter_user_id = any(p_user_ids)
                                 and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_seven_day_count,
                            (select count(1)
                             from brs.project_details pd
  				                       inner join flow.project p on p.id = pd.project_id
                                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                             where pd.source = 525 --Setter Gen
                                 and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                 and pd.closer_appointment_start is not null
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 30
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                 and pd.setter_user_id = any(p_user_ids)
                                 and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as thirty_day_count,
                            (select count(1)
                             from brs.project_details pd
  				                       inner join flow.project p on p.id = pd.project_id
                                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                             where pd.source = 525 --Setter Gen
                                 and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                 and pd.closer_appointment_start is not null
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 60
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 30
                                 and pd.setter_user_id = any(p_user_ids)
                                 and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_thirty_day_count,
                            (select count(1)
                             from brs.project_details pd
  				                       inner join flow.project p on p.id = pd.project_id
                                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                             where pd.source = 525 --Setter Gen
                                 and (pd.closer_appointment_outcome is null or pd.closer_appointment_outcome != 4) --Cancelled
                                 and pd.closer_appointment_start is not null
                                 and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                 and pd.setter_user_id = any(p_user_ids)
                                 and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as custom_date_range_count
                    from brs.setter_funnel
                    where id = 1
                ),

                --Appointments Pitched
                setter_funnel_2 as (
                    select id, name, ratio, ratio * p_base_expectation as expectation, display_order,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                                and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as today_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                                and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date = (now() at time zone 'US/Mountain')::date - 1
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as yesterday_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                                and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 7
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as seven_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                                and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 14
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 7
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_seven_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                                and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 30
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as thirty_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                                and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date >= (now() at time zone 'US/Mountain')::date - 60
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date <= (now() at time zone 'US/Mountain')::date - 30
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as prev_thirty_day_count,
                           (select count(1)
                            from brs.project_details pd
  				                      inner join flow.project p on p.id = pd.project_id
                                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                            where pd.source = 525 --Setter Gen
                                and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                                and ((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date between p_custom_start_date and p_custom_end_date
                                and pd.setter_user_id = any(p_user_ids)
                                and pd.setter_user_id = any(brs.limit_by_org_for_setters(Array[pd.setter_user_id]::integer[],p_org_ids,((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date))) as custom_date_range_count
                from brs.setter_funnel
                where id = 2
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
                       else cast(cast(thirty_day_count - prev_thirty_day_count as numeric(10,2)) / prev_thirty_day_count as numeric(6,2)) * 100
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
