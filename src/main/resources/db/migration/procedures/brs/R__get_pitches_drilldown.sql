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
                   pd.source_name as source,
                   (case when pd.first_appointment_pitched is not null
                             then pd.first_appointment_pitched
                         when pd.first_appointment_pitched is null
                             and pd.first_appointment_missed is not null
                             then pd.first_appointment_missed
                         else pd.closer_appointment_start
                         end) as appointment_date,
                   lov.name as appointment_outcome
            from flow.project p
                inner join brs.project_details pd on pd.project_id = p.id
                inner join flow.contact c on c.id = p.contact_id
                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.position_id = 4 and up.primary_flag is true)
                left join flow.list_of_value lov on (case when pd.first_appointment_pitched is not null
                                                              then pd.first_appointment_pitched_id
                                                          when pd.first_appointment_pitched is null
                                                              and pd.first_appointment_missed is not null
                                                              then pd.first_appointment_missed_id
                                                          else pd.closer_appointment_outcome
                                                          end) = lov.id
            where (((case when pd.first_appointment_pitched is not null
                              then pd.first_appointment_pitched
                          when pd.first_appointment_pitched is null
                              and pd.first_appointment_missed is not null
                              then pd.first_appointment_missed
                          else pd.closer_appointment_start
                          end) at time zone 'UTC') at time zone 'US/Mountain') :: date between v_start_date and v_end_date
                and pd.source in (525, 526) --(Setter Gen, Retargeted)
                and (case when pd.first_appointment_pitched is not null
                              then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                          when pd.first_appointment_pitched is null
                              and pd.first_appointment_missed is not null
                              then pd.first_appointment_missed_id in (2,3,1139,1140)
                          else pd.closer_appointment_outcome in (2,3,1139,1140)
                          end)
                and case when p_is_setter_mgr is true then up.org_id = p_setter_mgr_office_id
                    else pd.setter_user_id = p_user_id
                    end
                and pd.company_id = 3
        ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;
