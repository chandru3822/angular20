drop function if exists brs.duplicate_capacity_week( bigint, bigint, bigint, timestamp, timestamp);

CREATE OR REPLACE FUNCTION brs.duplicate_capacity_week(p_current_user_id bigint,
                                                       p_company_id bigint,
                                                       p_org_id bigint,
                                                       p_current_week_start_time timestamp,
                                                       p_current_week_end_time timestamp)
	RETURNS void
	LANGUAGE plpgsql AS
$$
DECLARE
	v_previous_week_start_time timestamp;
	v_previous_week_end_time timestamp;
BEGIN

	--notes:
	-- make sure all times saved to db are UTC
	-- make sure your constraint is added for this to work (via flyway to add it when the release to prod happens)

	v_previous_week_start_time = p_current_week_start_time - interval '1 week';
	v_previous_week_end_time = p_current_week_end_time - interval '1 week';

	--archive any records from the current week
	update flow.virtual_resource_slot_capacity vrsc
	set archived = true,
	    modified_by_id = p_current_user_id,
	    date_modified = now()
	where ((start_time between p_current_week_start_time and p_current_week_end_time)
		OR (end_time between p_current_week_start_time and p_current_week_end_time))
	  AND org_id = p_org_id
	  AND company_id = p_company_id;

--then upsert here (upsert = insert but on conflict do an update instead)
	insert into flow.virtual_resource_slot_capacity(company_id, org_id, max_capacity, start_time, end_time, date_modified, created_by_id, modified_by_id)
	select
		p_company_id, p_org_id,
		( case when
			       (select vrsc.max_capacity from flow.virtual_resource_slot_capacity vrsc
			        where ((vrsc.start_time between v_previous_week_start_time and v_previous_week_end_time)
				        OR (vrsc.end_time between v_previous_week_start_time and v_previous_week_end_time))
				      AND vrsc.org_id = p_org_id
				      AND vrsc.company_id = p_company_id) is not null then
			       (select vrsc.max_capacity from flow.virtual_resource_slot_capacity vrsc
			        where ((vrsc.start_time between v_previous_week_start_time and v_previous_week_end_time)
				        OR (vrsc.end_time between v_previous_week_start_time and v_previous_week_end_time))
				      AND vrsc.org_id = p_org_id
				      AND vrsc.company_id = p_company_id) end
			),
		p_current_week_start_time,
		p_current_week_end_time, now(),
		p_current_user_id,
		p_current_user_id
	on conflict (company_id, org_id, start_time, end_time)
		do update
		set
			archived = false,
			max_capacity = excluded.max_capacity,
			date_modified = now(),
			modified_by_id = excluded.modified_by_id;
END;
$$
