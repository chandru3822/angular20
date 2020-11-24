CREATE OR REPLACE FUNCTION brs.get_pitches_drilldown(p_user_id integer, p_quarter integer, p_is_setter_mgr boolean DEFAULT false, p_setter_mgr_office_id integer DEFAULT null)
	RETURNS SETOF json AS
$BODY$
declare
	v_start_date date;
	v_end_date date;
    v_year integer;
BEGIN
	select extract('year' from now())::integer
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
            select row_number() over (order by (concat(c.first_name, ' ', c.last_name))::bytea),
                   concat(c.first_name, ' ', c.last_name) as customer_name,
                   p.id,
                   pd.source as source_name,
                   pd.closer_appointment_start as appointment_date,
                   pd.closer_appointment_outcome_name as appointment_outcome
            from flow.project p
                inner join brs.project_details pd on pd.project_id = p.id
                inner join flow.contact c on c.id = p.contact_id
                inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                inner join flow.user u on u.id = upv.user_id
            where pd.closer_appointment_start between v_start_date and v_end_date
                and pd.source in (525, 526) --(Setter Gen, Retargeted)
                and pd.closer_appointment_outcome in (2, 3) --(Pitched, Missed)
                and upv.primary_flag is true
                and case when p_is_setter_mgr is true then upv.org_id = p_setter_mgr_office_id
                    else u.id = p_user_id
                    end
        ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;
